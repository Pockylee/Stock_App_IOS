//
//  StockChartsView.swift
//  stock_app
//
//  Created by Brian Li on 4/28/24.
//

import SwiftUI

struct StockChartsView: View {
    enum ChartType {
            case hourly, historical
        }
    
    @State private var selectedChart: ChartType = .hourly
    
    var body: some View {
        VStack {
            ZStack {
                if selectedChart == .hourly {
                // Placeholder for the hourly chart
                    Color.gray
                        .frame(height: 300)
                        .cornerRadius(10)
                        .overlay(Text("Hourly Chart Placeholder").foregroundColor(.white))
                        } else {
                            // Placeholder for the historical chart
                            Color.gray
                                .frame(height: 300)
                                .cornerRadius(10)
                                .overlay(Text("Historical Chart Placeholder").foregroundColor(.white))
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
}

#Preview {
    StockChartsView()
}
