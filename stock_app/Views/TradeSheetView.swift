//
//  TradeSheetView.swift
//  stock_app
//
//  Created by Brian Li on 5/2/24.
//

import SwiftUI

struct TradeSheetView: View {
    @ObservedObject var viewModel: StockDetailViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        
    }
}

#Preview {
    TradeSheetView(viewModel: StockDetailViewModel(stockSymbol: "AAPL"))
}
