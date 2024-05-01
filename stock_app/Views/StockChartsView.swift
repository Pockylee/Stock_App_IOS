//
//  StockChartsView.swift
//  stock_app
//
//  Created by Brian Li on 4/28/24.
//

import SwiftUI

struct StockChartsView: View {
    @ObservedObject var viewModel: StockDetailViewModel
    
    enum ChartType {
        case hourly, historical
    }
    
    @State private var selectedChart: ChartType = .hourly
    
    var body: some View {
        VStack {
            ZStack {
                if selectedChart == .hourly {
                    if viewModel.isLoading {
                        Text("Loading...")
                    } else {
                        WebView(htmlContent: summaryChartHtmlContent())
                            .frame(height: 300)
//                            .edgesIgnoringSafeArea(.horizontal)
                    }
                } else {
                    
                    if viewModel.isLoading {
                        Text("Loading...")
                    } else {
                        WebView(htmlContent: historicalChartHtmlContent())
                            .frame(height: 300)
//                            .edgesIgnoringSafeArea(.horizontal)
                    }
                }
            }
            //                    .padding()
            
            HStack {
                Spacer()
                Button(action: {
                    selectedChart = .hourly
                }) {
                    VStack{
                        Image(systemName: "chart.xyaxis.line")
                            .imageScale(.large)
                            .foregroundColor(selectedChart == .hourly ? .blue : .gray)
                        Text("Hourly")
                            .font(.caption2)
                            .foregroundColor(selectedChart == .hourly ? .blue : .gray)
                    }
                }
                Spacer()
                Button(action: {
                    selectedChart = .historical
                }) {
                    VStack{
                        Image(systemName: "clock.fill")
                            .imageScale(.large)
                            .foregroundColor(selectedChart == .historical ? .blue : .gray)
                        Text("Historical")
                            .font(.caption2)
                            .foregroundColor(selectedChart == .historical ? .blue : .gray)
                    }
                }
                Spacer()
            }
        }
    }
    private func summaryChartHtmlContent() -> String {
        let dataString = viewModel.summaryChartData.map { entry -> String in
            let time = entry["t"] as? Double ?? 0
            let close = entry["c"] as? Double ?? 0
            return "[\(time), \(close)]"
        }.joined(separator: ", ")
        
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <title>\(viewModel.stockSymbol) Hourly Price Variation</title>
                <script src="https://code.highcharts.com/highcharts.js"></script>
                <style>
                            body, html {
                                            margin: 0;
                                            padding: 0;
                                        
                                        }
                                        #chart-container {
                                            height: 800px; /* Fixed height */
                                            width: auto;

                            overflow-x: auto; /* Allows horizontal scrolling */

                                        }
                        </style>
            </head>
            <body>
                <div id="chart-container"></div>
                <script>
                    Highcharts.chart('chart-container', {
                        chart: {
                            type: 'line',
                            scrollablePlotArea: {
                                                 minWidth: 2000,
                                                    scrollPositionX: 0 // Start the chart scrolled to the left
                                                }
                        },
                        title: {
                            text: '\(viewModel.stockSymbol) Hourly Price Variation'
                        },
                        xAxis: {
                            type: 'datetime',
                            title: {
                                text: 'Time'
                            }
                        },
                        yAxis: {
                            title: {
                                text: 'Price'
                            }
                        },
                        series: [{
                            name: '\(viewModel.stockSymbol)',
                            data: [\(dataString)],
                            color: 'red', /* Sets the line color to red */
                            marker: {
                                    enabled: false /* Hides the markers */
                                },
                            tooltip: {
                                valueDecimals: 2
                            }
                        }]
                    });
                </script>
            </body>
            </html>
            """
    }
    
    private func historicalChartHtmlContent() -> String {
        // Format data for price and volume as needed
        let priceDataString = viewModel.historicalChartData.map { entry -> String in
            let time = entry["t"] as? Double ?? 0
            let open = entry["o"] as? Double ?? 0
            let high = entry["h"] as? Double ?? 0
            let low = entry["l"] as? Double ?? 0
            let close = entry["c"] as? Double ?? 0
            return "[\(time), \(open), \(high), \(low), \(close)]"
        }.joined(separator: ", ")

        let volumeDataString = viewModel.historicalChartData.map { entry -> String in
            let time = entry["t"] as? Double ?? 0
            let volume = entry["v"] as? Double ?? 0
            return "[\(time), \(volume)]"
        }.joined(separator: ", ")

        // HTML and JavaScript to configure and display the chart
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <title>\(viewModel.stockSymbol) Historical Data</title>
                <script src="https://code.highcharts.com/stock/highstock.js"></script>
                <script src="https://code.highcharts.com/modules/exporting.js"></script>
                <script src="https://code.highcharts.com/modules/accessibility.js"></script>
                <script src="https://code.highcharts.com/indicators/indicators.js"></script>
                <script src="https://code.highcharts.com/indicators/volume-by-price.js"></script>
                <style>
                    body, html {
                        margin: 0;
                        padding: 0;
                        height: 100%;
                    }
                    #chart-container {
                        height: 100%;
                        width: 100%;
                    }
                </style>
            </head>
            <body>
                <div id="chart-container"></div>
                <script>
                    Highcharts.stockChart('chart-container', {
                        rangeSelector: {
                            selected: 1
                        },
                        title: {
                            text: '\(viewModel.stockSymbol) Historical Price'
                        },
                        series: [{
                            type: 'candlestick',
                            name: '\(viewModel.stockSymbol)',
                            data: [\(priceDataString)],
                            tooltip: {
                                valueDecimals: 2
                            }
                        }, {
                            type: 'column',
                            name: 'Volume',
                            data: [\(volumeDataString)],
                            yAxis: 1
                        }],
                        yAxis: [{
                            labels: {
                                align: 'right',
                                x: -3
                            },
                            title: {
                                text: 'OHLC'
                            },
                            height: '60%',
                            lineWidth: 2
                        }, {
                            labels: {
                                align: 'right',
                                x: -3
                            },
                            title: {
                                text: 'Volume'
                            },
                            top: '65%',
                            height: '35%',
                            lineWidth: 2
                        }],
                        responsive: {
                            rules: [{
                                condition: {
                                    maxWidth: 800
                                },
                                chartOptions: {
                                    chart: {
                                        height: 600
                                    },
                                    subtitle: {
                                        text: null
                                    },
                                    navigator: {
                                        enabled: false
                                    }
                                }
                            }]
                        }
                    });
                </script>
            </body>
            </html>
            """
    }



}

#Preview {
    StockChartsView(viewModel: StockDetailViewModel(stockSymbol: "AAPL"))
}
