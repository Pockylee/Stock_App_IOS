//
//  PortfolioItemView.swift
//  stock_app
//
//  Created by Brian Li on 4/20/24.
//

import SwiftUI

struct PortfolioItemView: View {
    let stockItem: StockItem
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(stockItem.symbol)
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundColor(.primary)
                    Text("\(stockItem.shares) shares")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("$\(stockItem.currentValue, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.primary)
                    HStack(spacing: 4) {
                        Image(systemName: stockItem.isPositiveChange ? "arrow.up.right" : "arrow.down.right")
                            .foregroundColor(stockItem.isPositiveChange ? .green : .red)
                            .padding(.trailing, 10.0)
                        Text("$\(stockItem.changeValue, specifier: "%.2f") (\(stockItem.changePercentage, specifier: "%.2f")%)")
                            .foregroundColor(stockItem.isPositiveChange ? .green : .red)
                    }
                    .font(.subheadline)
                }
            }
        }
    }


struct PortfolioItemView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioItemView(stockItem: StockItem(
            symbol: "AAPL",
            shares: 3,
            currentValue: 513.06,
            changeValue: -0.63,
            changePercentage: -0.12,
            isPositiveChange: false
        ))
    }
}
