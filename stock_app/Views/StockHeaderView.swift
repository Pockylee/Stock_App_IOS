//
//  StockHeaderView.swift
//  stock_app
//
//  Created by Brian Li on 4/21/24.
//

import SwiftUI

struct StockHeaderView: View {
    var symbol: String
        var companyName: String
        var currentPrice: Double
        var priceChange: Double
        var percentageChange: Double
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(companyName)
                    .font(.title2)
                    .foregroundColor(.gray)
                HStack {
                    Text("$\(currentPrice, specifier: "%.2f")")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(priceChange > 0 ? "↑ $\(priceChange, specifier: "%.2f") (\(percentageChange, specifier: "%.2f")%)" : "↓ $\(priceChange, specifier: "%.2f") (\(percentageChange, specifier: "%.2f")%)")
                        .foregroundColor(priceChange > 0 ? .green : .red)
                }
            }
        }
    }

//#Preview {
//    StockHeaderView()
//}
