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
                    .onDelete(perform: deleteItem)
                    .onMove(perform: moveItem)


        }
    func deleteItem(at offsets: IndexSet) {
            guard let index = offsets.first else { return }
            let deletedSymbol = viewModel.favoritesItems[index].symbol
            viewModel.deleteItemWithSymbol(symbol: deletedSymbol)
        }
    func moveItem(from source: IndexSet, to destination: Int) {
            viewModel.favoritesItems.move(fromOffsets: source, toOffset: destination)
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
