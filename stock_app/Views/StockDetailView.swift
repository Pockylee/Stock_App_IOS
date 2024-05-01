//
//  StockDetailView.swift
//  stock_app
//
//  Created by Brian Li on 4/20/24.
//

import SwiftUI

struct StockDetailView: View {
    @StateObject var viewModel: StockDetailViewModel
    @State private var isStockInWatchlist = true
    
    init(stockSymbol: String) {
        _viewModel = StateObject(wrappedValue: StockDetailViewModel(stockSymbol: stockSymbol))
    }
    
    var body: some View {
        ScrollView{
            StockHeaderView(viewModel: viewModel)
            StockChartsView(viewModel: viewModel)
            StockProfolioView(viewModel: viewModel)
            StockStatsView(viewModel: viewModel)
            StockAboutView(viewModel: viewModel)
            StockInsightsView(viewModel: viewModel)
            StockTrendsEPSView()
            StockNewsView(viewModel: viewModel)
            
        }
        .navigationBarTitle(viewModel.stockSymbol, displayMode: .large)
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !isStockInWatchlist {
                    Button(action: {
                        // Actions to perform when the Add button is tapped
                        print("Add button tapped")
                        addToWatchlist()
                        
                        // Perform actions to add the stock to the watchlist
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .onAppear {
            // Call API to check if the stock is in the watchlist
            checkStockInWatchlist()
        }
    }
    
    func checkStockInWatchlist() {
        guard let url = URL(string: "\(APIConfig.baseURL)/watchlist/check/\(viewModel.stockSymbol)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error checking stock in watchlist:", error?.localizedDescription ?? "Unknown error")
                return
            }
            if let isInWatchlist = try? JSONDecoder().decode(Bool.self, from: data) {
                DispatchQueue.main.async {
                    self.isStockInWatchlist = isInWatchlist
                }
            }
        }.resume()
    }
    
    func addToWatchlist() {
        guard let url = URL(string: "\(APIConfig.baseURL)/watchlist") else { return }
        
        // Create the request body
        let requestBody: [String: Any] = [
            "symbol": viewModel.stockSymbol,
            "companyName": viewModel.companyName // Assuming you have this property in your view model
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//                print("Error adding stock to watchlist:", error?.localizedDescription ?? "Unknown error")
//                return
//            }
            
            // Handle the response if needed
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("Stock added to watchlist successfully")
                    DispatchQueue.main.async {
                        self.isStockInWatchlist = true
                    }
                } else {
                    print("Failed to add stock to watchlist, status code: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
}

#Preview {
    StockDetailView(stockSymbol: "AAPL")
}
