//
//  StockProfolioView.swift
//  stock_app
//
//  Created by Brian Li on 4/28/24.
//

import SwiftUI

struct StockProfolioView: View {
    @ObservedObject var viewModel: StockDetailViewModel
    @ObservedObject var portfolioViewModel: PortfolioViewModel
    @State private var showTrade = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Portfolio")
                .font(.title2)
                .fontWeight(.medium)
                .padding(.bottom, 5)
            
            HStack{
                if viewModel.sharesOwned > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Shares Owned: \(viewModel.sharesOwned)")
                        Text("Avg. Cost / Share: $\(viewModel.avgCostPerShare, specifier: "%.2f")")
                        Text("Total Cost: $\(viewModel.totalCost, specifier: "%.2f")")
                        HStack {
                            Text("Change: ")
                            Text("$\(viewModel.change >= 0 ? "+" : "")\(viewModel.change, specifier: "%.2f")")
                                .foregroundColor(viewModel.change >= 0 ? .green : .red)
                        }
                        HStack {
                            Text("Market Value: ")
                            Text("$\(viewModel.marketValue, specifier: "%.2f")")
                                .foregroundColor(viewModel.change >= 0 ? .green : .red)
                        }
                    }
                } else {
                    Text("You have 0 shares of \(viewModel.stockSymbol).\nStart trading!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: {
                    showTrade = true                }) {
                        Text("Trade")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 20)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .background(Color.green)
                            .cornerRadius(30)
                    }
                    .padding(.horizontal)
                
                    .sheet(isPresented: $showTrade) {
                        TradeSheetView(viewModel: viewModel, portfolioViewModel: portfolioViewModel)
                    }
                
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

#Preview {
    StockProfolioView(viewModel: StockDetailViewModel(stockSymbol: "AAPL"), portfolioViewModel: PortfolioViewModel())
}
