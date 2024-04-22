//
//  PortfolioViewModel.swift
//  stock_app
//
//  Created by Brian Li on 4/20/24.
//

import Foundation

class PortfolioViewModel: ObservableObject {
    @Published var netWorth: Double = 0.0
    @Published var cashBalance: Double = 0.0
    @Published var portfolioItems: [StockItem] = []
    
    init() {
            loadData()
        }
        
        func loadData() {
            // Dummy data for preview and testing
            netWorth = 25006.75
            cashBalance = 21747.26
            portfolioItems = [
                StockItem(symbol: "AAPL", shares: 3, currentValue: 513.06, changeValue: -0.63, changePercentage: -0.12, isPositiveChange: false),
                StockItem(symbol: "NVDA", shares: 3, currentValue: 2746.44, changeValue: 7.38, changePercentage: 0.27, isPositiveChange: true)
                // Add more items as needed
            ]
        }
    
    func fetchPortfolioData() {
        NetworkService.fetchNetWorth { [weak self] netWorth in
            self?.netWorth = netWorth
        }
        NetworkService.fetchCashBalance { [weak self] cashBalance in
            self?.cashBalance = cashBalance
        }
        // Repeat for other data, such as fetching stock items
    }
    
    // Add methods for fetching from different APIs
}


class NetworkService {
    static func fetchNetWorth(completion: @escaping (Double) -> Void) {
        // Make API call and return net worth
    }
    
    static func fetchCashBalance(completion: @escaping (Double) -> Void) {
        // Make API call and return cash balance
    }
    
    // Add methods for different API endpoints
}


struct StockItem: Identifiable {
    let id = UUID()
    let symbol: String
    let shares: Int
    let currentValue: Double
    let changeValue: Double
    let changePercentage: Double
    let isPositiveChange: Bool
}
