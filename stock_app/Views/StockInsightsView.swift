//
//  StockInsightsView.swift
//  stock_app
//
//  Created by Brian Li on 4/29/24.
//

import SwiftUI

struct StockInsightsView: View {
    @ObservedObject var viewModel: StockDetailViewModel
    
//    var totalMSPR: Double = -654.26
//    var positiveMSPR: Double = 200
//    var negativeMSPR: Double = -854.26
//    
//    var totalChange: Double = -654.26
//    var positiveChange: Double = 200
//    var negativeChange: Double = -854.26
    
   
    var body: some View {
        VStack() {
            Text("Insights")
                .font(.title2)
                .fontWeight(.medium)
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .center){
                Text("Insider Sentiments")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.bottom, 5)
                HStack{
                    VStack(alignment: .leading, spacing: 10){
                        Text("Apple Inc")
                        Divider()
                        Text("Total")
                        Divider()
                        Text("Positive")
                        Divider()
                        Text("Negative")
                        Divider()
                    }
                    .fontWeight(.bold)
                    VStack(alignment: .leading, spacing: 10){
                        Text("MSPR")
                            .fontWeight(.bold)
                        Divider()
                        Text("\(viewModel.totalMspChange, specifier: "%.2f")")
                        Divider()
                        Text("\(viewModel.positiveMspChange, specifier: "%.2f")")
                        Divider()
                        Text("\(viewModel.negativeMspChange, specifier: "%.2f")")
                        Divider()
                    }
                    VStack(alignment: .leading, spacing: 10){
                        Text("Change")
                            .fontWeight(.bold)
                        Divider()
                        Text("\(viewModel.totalChange, specifier: "%.2f")")
                        Divider()
                        Text("\(viewModel.positiveChange, specifier: "%.2f")")
                        Divider()
                        Text("\(viewModel.negativeChange, specifier: "%.2f")")
                        Divider()
                    }
                    
                }
            }
            
        }
    }
}

#Preview {
    StockInsightsView(viewModel: StockDetailViewModel(stockSymbol: "AAPL"))
}
