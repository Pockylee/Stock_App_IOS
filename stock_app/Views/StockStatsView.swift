//
//  StockStatsView.swift
//  stock_app
//
//  Created by Brian Li on 4/29/24.
//

import SwiftUI

struct StockStatsView: View {
//    var highPrice: Double = 177.49
//    var lowPrice: Double = 170.85
//    var openPrice: Double = 177.00
//    var prevClosePrice: Double = 178.67
    @ObservedObject var viewModel: StockDetailViewModel
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Stats")
                .font(.title2)
                .fontWeight(.medium)
                .padding(.bottom, 5)
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("High Price: ")
                            .fontWeight(.bold)
                        Text("\(viewModel.highPrice, specifier: "%.2f")")
                    }
                    HStack {
                        Text("Low Price: ")
                            .fontWeight(.bold)
                        Text("\(viewModel.lowPrice, specifier: "%.2f")")
                    }
                }
                
                Spacer()
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Open Price: ")
                            .fontWeight(.bold)
                        Text("\(viewModel.openPrice, specifier: "%.2f")")
                    }
                    HStack {
                        Text("Prev. Close: ")
                            .fontWeight(.bold)
                        Text("\(viewModel.prevClosePrice, specifier: "%.2f")")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview {
    StockStatsView(viewModel: StockDetailViewModel(stockSymbol: "AAPL"))
}
