//
//  StockDetailView.swift
//  stock_app
//
//  Created by Brian Li on 4/20/24.
//

import SwiftUI

struct StockDetailView: View {
    @StateObject var viewModel: StockDetailViewModel
        
        init(stockSymbol: String) {
            _viewModel = StateObject(wrappedValue: StockDetailViewModel(stockSymbol: stockSymbol))
        }
    
    var body: some View {
        ScrollView{
            StockHeaderView(viewModel: viewModel)
            StockChartsView()
            StockProfolioView(viewModel: viewModel)
            StockStatsView()
            StockAboutView()
            StockInsightsView()
            StockTrendsEPSView()
           
        }
        .navigationBarTitle(viewModel.stockSymbol, displayMode: .large)
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal)
    }
}

#Preview {
    StockDetailView(stockSymbol: "AAPL")
}
