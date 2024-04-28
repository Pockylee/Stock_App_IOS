//
//  StockDetailView.swift
//  stock_app
//
//  Created by Brian Li on 4/20/24.
//

import SwiftUI

struct StockDetailView: View {
    
    let stockSymbol = "AAPL"
    let companyName = "Apple Inc"
    let currentPrice = 171.09
    let priceChange = -7.58
    let percentageChange = -4.24
    
    
    var body: some View {
        ScrollView{
            StockHeaderView(symbol: stockSymbol, companyName: companyName, currentPrice: currentPrice, priceChange: priceChange, percentageChange: percentageChange)
            StockChartsView()
            StockProfolioView()
           
        }
        .navigationBarTitle(stockSymbol, displayMode: .large)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    StockDetailView()
}
