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
    
    private var updateTimer: Timer?
    
    init() {
        loadinitData()
        fetchPortfolioData()
        startUpdatingPortfolio()
    }
    
    func loadinitData() {
    }
    
    func fetchPortfolioData() {
        NetworkService.fetchCashBalance { [weak self] cashBalance in
            self?.cashBalance = cashBalance
            self?.calculateNetWorth()
        }
        NetworkService.fetchPortfolioItems { [weak self] items in
            self?.portfolioItems = items
            self?.updatePortfolioItemsWithCurrentValues()
        }
    }
    
    private func updatePortfolioItemsWithCurrentValues() {
        for index in portfolioItems.indices {
            let symbol = portfolioItems[index].symbol
            NetworkService.fetchStockPriceDetails(for: symbol) { result in
                switch result {
                case .success(let details):
                    DispatchQueue.main.async {
                        self.portfolioItems[index].currentValue = details.c
                        self.portfolioItems[index].changeValue = details.d
                        self.portfolioItems[index].changePercentage = details.dp
                        self.portfolioItems[index].isPositiveChange = details.d >= 0
                        self.calculateNetWorth()

                    }
                case .failure(let error):
                    print("Error fetching details for \(symbol): \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func startUpdatingPortfolio() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
            self.updatePortfolioItemsWithCurrentValues()
        }
    }
    
    private func calculateNetWorth() {
        if portfolioItems.isEmpty {
            // If there are no portfolio items, set net worth to the cash balance only.
//            print("no portfoliosadfadfsadfsadfadfadfsadfaddfa")
            netWorth = cashBalance}
            else{
//                print("no portfoliosadfadfsadfsadfadfadfsadfadfa")
                netWorth = portfolioItems.reduce(0) { $0 + ($1.currentValue * Double($1.shares)) }
                netWorth += cashBalance // Include cash balance in net worth calculation
            }
        }
    
    deinit {
        updateTimer?.invalidate()
    }
}

//https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AAPL.png


struct StockItem: Identifiable {
    let id = UUID()
    let symbol: String
    let shares: Int
    var currentValue: Double
    var changeValue: Double
    var changePercentage: Double
    var isPositiveChange: Bool
}

struct PortfolioAPIItem: Decodable {
    let symbol: String
    let quantity: Int
}
