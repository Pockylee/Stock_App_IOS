//
//  PortfolioView.swift
//  stock_app
//
//  Created by Brian Li on 4/18/24.
//

import SwiftUI

struct PortfolioView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    // Dummy data for preview and testing
    
    var body: some View {
                    HeaderView(netWorth: viewModel.netWorth, cashBalance: viewModel.cashBalance)

                    ForEach(viewModel.portfolioItems) { item in
                        NavigationLink(destination: StockDetailView()) {
                            PortfolioItemView(stockItem: item)
                        }
                    }


        }
}

    // Define the HeaderView
    struct HeaderView: View {
        var netWorth: Double
        var cashBalance: Double
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text("Net Worth")
                        .font(.title3)
                        .fontWeight(.medium)
                    Text("$\(netWorth, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Cash Balance")
                        .font(.title3)
                        .fontWeight(.medium)
                    Text("$\(cashBalance, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    



//#Preview {
//    PortfolioView()
//}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView(viewModel: PortfolioViewModel())
    }
}
