//
//  StockProfolioView.swift
//  stock_app
//
//  Created by Brian Li on 4/28/24.
//

import SwiftUI

struct StockProfolioView: View {
    var sharesOwned: Int = 0
    var stockSymbol: String = "AAPL"
    
    var body: some View {
            VStack(alignment: .leading) {
                Text("Portfolio")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.bottom, 5)

                HStack{
                    Text("You have \(sharesOwned) shares of \(stockSymbol).\nStart trading!")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: {
                        // Action to trade
                    }) {
                        Text("Trade")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(20)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    
}

#Preview {
    StockProfolioView()
}
