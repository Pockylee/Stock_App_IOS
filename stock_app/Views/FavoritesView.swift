//
//  FavoritesView.swift
//  stock_app
//
//  Created by Brian Li on 4/18/24.
//

import SwiftUI

struct FavoritesView: View {
    
    @ObservedObject var viewModel: FavoritesViewModel
    // Dummy data for preview and testing
    
    var body: some View {
                    ForEach(viewModel.favoritesItems) { item in
                        NavigationLink(destination: StockDetailView(stockSymbol: item.symbol)) {
                            FavoritesItemView(favStockItem: item)
                        }
                    }


        }
}
//#Preview {
//    PortfolioView()
//}

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(viewModel: FavoritesViewModel())
    }
}
