//
//  FavoritesViewModel.swift
//  stock_app
//
//  Created by Brian Li on 4/21/24.
//

import Foundation

class FavoritesViewModel: ObservableObject {
    @Published var favoritesItems: [FavStockItem] = []
    
    init() {
            loadData()
        }
        
        func loadData() {
            // Dummy data for preview and testing
            favoritesItems = [
                FavStockItem(symbol: "NVDA", companyName: "NVDIA Corp", currentValue: 513.06, changeValue: -0.63, changePercentage: -0.12, isPositiveChange: false),
                FavStockItem(symbol: "AAPL", companyName: "Apple Inc", currentValue: 2746.44, changeValue: 7.38, changePercentage: 0.27, isPositiveChange: true)
                // Add more items as needed
            ]
        }
    
    func fetchFavoritesData() {
        // Repeat for other data, such as fetching stock items
    }
    
    // Add methods for fetching from different APIs
}


struct FavStockItem: Identifiable {
    let id = UUID()
    let symbol: String
    let companyName: String
    let currentValue: Double
    let changeValue: Double
    let changePercentage: Double
    let isPositiveChange: Bool
}
