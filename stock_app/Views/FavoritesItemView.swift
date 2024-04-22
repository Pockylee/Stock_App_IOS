//
//  FavoritesItemView.swift
//  stock_app
//
//  Created by Brian Li on 4/21/24.
//

import SwiftUI

struct FavoritesItemView: View {
    let favStockItem: FavStockItem
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(favStockItem.symbol)
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundColor(.primary)
                    Text("\(favStockItem.companyName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("$\(favStockItem.currentValue, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.primary)
                    HStack(spacing: 4) {
                        Image(systemName: favStockItem.isPositiveChange ? "arrow.up.right" : "arrow.down.right")
                            .foregroundColor(favStockItem.isPositiveChange ? .green : .red)
                            .padding(.trailing, 10.0)
                        Text("$\(favStockItem.changeValue, specifier: "%.2f") (\(favStockItem.changePercentage, specifier: "%.2f")%)")
                            .foregroundColor(favStockItem.isPositiveChange ? .green : .red)
                    }
                    .font(.subheadline)
                }
            }
        }
    }


struct FavoritesItemView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesItemView(favStockItem: FavStockItem(
            symbol: "AAPL",
            companyName: "Apple Inc",
            currentValue: 513.06,
            changeValue: -0.63,
            changePercentage: -0.12,
            isPositiveChange: false
        ))
    }
}
