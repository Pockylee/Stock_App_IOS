//
//  StockHeaderView.swift
//  stock_app
//
//  Created by Brian Li on 4/21/24.
//

import SwiftUI

struct StockHeaderView: View {
    @ObservedObject var viewModel: StockDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.companyName)
                .font(.title2)
                .foregroundColor(.gray)
            
            HStack {
                Text("$\(viewModel.currentPrice, specifier: "%.2f")")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Image(systemName: viewModel.priceChange > 0 ? "arrow.up.right" : "arrow.down.right")
                    .foregroundColor(viewModel.priceChange > 0 ? .green : .red)
                
                Text("\(viewModel.priceChange > 0 ? "+" : "")\(viewModel.priceChange, specifier: "%.2f") (\(viewModel.percentageChange, specifier: "%.2f")%)")
                    .foregroundColor(viewModel.priceChange > 0 ? .green : .red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct StockHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        StockHeaderView(viewModel: StockDetailViewModel(stockSymbol: "AAPL"))
    }
}


//struct StockHeaderView: View {
//    @ObservedObject var viewModel: StockHeaderViewModel
//    
////    var symbol: String
////    var companyName: String
////    var currentPrice: Double
////    var priceChange: Double
////    var percentageChange: Double
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(companyName)
//                .font(.title2)
//                .foregroundColor(.gray)
//            
//            HStack {
//                Text("$\(currentPrice, specifier: "%.2f")")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                
//                Image(systemName: priceChange > 0 ? "arrow.up.right" : "arrow.down.right")
//                    .foregroundColor(priceChange > 0 ? .green : .red)
//                
//                Text("\(priceChange > 0 ? "+" : "")\(priceChange, specifier: "%.2f") (\(percentageChange, specifier: "%.2f")%)")
//                    .foregroundColor(priceChange > 0 ? .green : .red)
//            }
//            .padding(.top, 1.0)
//        }
//        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
//        
//    }
//}
//
//#Preview {
////    StockHeaderView()
//    StockHeaderView(
//        symbol: "AAPL",
//        companyName: "Apple Inc.",
//        currentPrice: 171.09,
//        priceChange: -7.58,
//        percentageChange: -4.24
//    )
//}
//
