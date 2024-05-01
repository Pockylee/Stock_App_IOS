//
//  FavoritesViewModel.swift
//  stock_app
//
//  Created by Brian Li on 4/21/24.
//

import Foundation

class FavoritesViewModel: ObservableObject {
    @Published var favoritesItems: [FavStockItem] = []
    
    private var updateTimer: Timer?
    
    init() {
        loadData()
        fetchFavoriteData()
        startUpdatingFavorites()
    }
    
    func loadData() {
        // Dummy data for preview and testing
        //        favoritesItems = [
        //            FavStockItem(symbol: "NVDA", companyName: "NVDIA Corp", currentValue: 513.06, changeValue: -0.63, changePercentage: -0.12, isPositiveChange: false),
        //            FavStockItem(symbol: "AAPL", companyName: "Apple Inc", currentValue: 2746.44, changeValue: 7.38, changePercentage: 0.27, isPositiveChange: true)
        //            // Add more items as needed
        //        ]
    }
    
    func fetchFavoriteData() {
        NetworkService.fetchFavoriteItems { [weak self] items in
            self?.favoritesItems = items
            self?.updateFavoritesItemsWithCurrentValues()
        }
    }
    
    private func updateFavoritesItemsWithCurrentValues() {
        for index in favoritesItems.indices {
            let symbol = favoritesItems[index].symbol
            NetworkService.fetchStockPriceDetails(for: symbol) { result in
                switch result {
                case .success(let details):
                    DispatchQueue.main.async {
                        self.favoritesItems[index].currentValue = details.c
                        self.favoritesItems[index].changeValue = details.d
                        self.favoritesItems[index].changePercentage = details.dp
                        self.favoritesItems[index].isPositiveChange = details.d >= 0
                    }
                case .failure(let error):
                    print("Error fetching details for \(symbol): \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func startUpdatingFavorites() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
            self.updateFavoritesItemsWithCurrentValues()
        }
    }
    
    func refreshData() {
            fetchFavoriteData()
        startUpdatingFavorites()
        }
    
    func deleteItemWithSymbol(symbol: String) {
            guard let url = URL(string: "\(APIConfig.baseURL)/watchlist/\(symbol)") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error deleting item: \(error)")
                } else if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    print("Unexpected response: \(httpResponse)")
                } else {
                    // Handle successful deletion, such as refreshing the data
                    self.refreshData()
                }
            }.resume()
        }
    
    
    deinit {
        updateTimer?.invalidate()
    }

}


struct FavStockItem: Identifiable {
    let id = UUID()
    let symbol: String
    let companyName: String
    var currentValue: Double
    var changeValue: Double
    var changePercentage: Double
    var isPositiveChange: Bool
}

struct FavoriteAPIItem: Decodable {
    let symbol: String
    let companyName: String
}
