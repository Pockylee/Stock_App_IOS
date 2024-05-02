//
//  StockTrendsEPSView.swift
//  stock_app
//
//  Created by Brian Li on 4/30/24.
//

import SwiftUI

struct StockTrendsEPSView: View {
    @ObservedObject var viewModel: StockDetailViewModel
    var body: some View {
        VStack{
            ChartWebView(chartType: .recommendation, viewModel: RecommendationChartViewModel(stockSymbol: viewModel.stockSymbol))
//                        WebView(htmlContent: summaryChartHtmlContent())
                .frame(height: 300)
            ChartWebView(chartType: .eps, viewModel: EPSChartViewModel(stockSymbol: viewModel.stockSymbol))
                .frame(height: 300)

        }
    }
}

#Preview {
    StockTrendsEPSView(viewModel: StockDetailViewModel(stockSymbol: "AAPL"))
}
