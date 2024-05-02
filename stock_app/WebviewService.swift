//
//  WebviewService.swift
//  stock_app
//
//  Created by Brian Li on 5/1/24.
//

//import Foundation
import SwiftUI
import WebKit

struct ChartWebView: UIViewRepresentable {
    var chartType: ChartType
    var viewModel: Any
    
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Choose HTML file based on chartType
        let htmlFileName = htmlFile(for: chartType)
        if let filePath = Bundle.main.path(forResource: htmlFileName, ofType: "html") {
            let fileUrl = URL(fileURLWithPath: filePath)
            let request = URLRequest(url: fileUrl)
            uiView.load(request)
        }
        
        // Inject JavaScript to pass data when page loads
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let jsCode = prepareJavaScriptCode(for: chartType, viewModel: viewModel) {
                uiView.evaluateJavaScript(jsCode, completionHandler: nil)
            }
        }
    }
    
    private func htmlFile(for chartType: ChartType) -> String {
        switch chartType {
        case .hourly:
            return "hourlyChart"
        case .historical:
            return "monthlyChart"
        case .recommendation:
            return "recommendationChart"
        case .eps:
            return "epsChart"
        }
    }
    
    private func prepareJavaScriptCode(for chartType: ChartType, viewModel: Any) -> String? {
        // Generate JavaScript code to inject the data
        switch chartType {
        case .hourly:
            if let vm = viewModel as? HourlyChartViewModel {
                // Prepare data as a string in the format expected by Highcharts
                let dataString = vm.data.timestamps.enumerated().map { (index, timestamp) in
                    "[\(timestamp * 1000), \(vm.data.closes[index])]"  // Convert timestamps to milliseconds
                }.joined(separator: ",")
                //                print(dataString)
                
                // JavaScript code to update the chart
                return """
                            if (window.updateChartData) {
                                updateChartData("\(vm.stockSymbol)", [\(dataString)]);
                            } else {
                                console.error('updateChartData function not defined.');
                            }
                            """
            } else {
                print("ViewModel casting failed for hourly chart.")
                return nil
            }
            // Repeat for other chart types
        case .historical:
            if let vm = viewModel as? HistoricalChartViewModel {
                let dataString = vm.data.timestamps.enumerated().map { (index, timestamp) in
                    // Convert timestamp to milliseconds and format the data string as a JavaScript object
                    let timestampMillis = timestamp * 1000  // Convert to milliseconds
                    let open = vm.data.openPrices[index]
                    let high = vm.data.highPrices[index]
                    let low = vm.data.lowPrices[index]
                    let close = vm.data.closePrices[index]
                    let volume = vm.data.volumes[index]
                    
                    return """
                            {
                                "t": \(timestampMillis),
                                "o": \(open),
                                "h": \(high),
                                "l": \(low),
                                "c": \(close),
                                "v": \(volume)
                            }
                            """
                }.joined(separator: ", ")
                return """
                                if (window.renderMonthlyChart) {
                                    renderMonthlyChart("\(vm.stockSymbol)", [\(dataString)]);
                                } else {
                                    console.error('renderMonthlyChart function not defined.');
                                }
                                """
            }
        case .recommendation:
            if let vm = viewModel as? RecommendationChartViewModel {
                do {
                    let jsonData = try JSONEncoder().encode(vm.recommendationData)
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        //                        print(jsonString)
                        return """
                                        if (window.renderRecommendationChart) {
                                            renderRecommendationChart("\(vm.stockSymbol)", \(jsonString));
                                        } else {
                                            console.error('renderRecommendationChart function not defined.');
                                        }
                                        """
                    }
                } catch {
                    print("Failed to encode recommendation data: \(error)")
                }
            } else {
                print("ViewModel casting failed for recommendation chart.")
            }
        case .eps:
            if let vm = viewModel as? EPSChartViewModel {
                let dataString = vm.epsData.map { data in
                    // Format each entry as a JavaScript object
                        """
                        {
                            "actual": \(data.actual),
                            "estimate": \(data.estimate),
                            "period": "\(data.period)",
                            "quarter": \(data.quarter),
                            "surprise": \(data.surprise),
                            "surprisePercent": \(data.surprisePercent)
                        }
                        """
                }.joined(separator: ", ")
                
                // JavaScript code to update the EPS chart
                return """
                           if (window.renderEPSChart) {
                               renderEPSChart("\(vm.stockSymbol)", [\(dataString)]);
                           } else {
                               console.error('renderEPSChart function not defined.');
                           }
                           """
            } else {
                print("ViewModel casting failed for EPS chart.")
                return nil
            }        }
        
        return nil
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
        
    }
    class WebViewCoordinator: NSObject, WKScriptMessageHandler {
        var parent: ChartWebView
        
        init(_ parent: ChartWebView) {
            self.parent = parent
        }
        
        // This function catches messages from the web content
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "log" {
                print("JavaScript log: \(message.body)")
            }
        }
    }
    
    
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: ChartWebView
        
        init(_ parent: ChartWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let jsCode = parent.prepareJavaScriptCode(for: parent.chartType, viewModel: parent.viewModel) {
                webView.evaluateJavaScript(jsCode, completionHandler: { result, error in
                    if let error = error {
                        print("JavaScript execution error: \(error.localizedDescription)")
                    }
                })
            }
        }
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
}




enum ChartType {
    case hourly, historical, recommendation, eps
}
