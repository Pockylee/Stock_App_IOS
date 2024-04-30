//
//  StockDetailViewModel.swift
//  stock_app
//
//  Created by Brian Li on 4/30/24.
//

import Foundation

class StockDetailViewModel: ObservableObject {
    // Published properties that the header view will use
    @Published var companyName: String = ""
    @Published var currentPrice: Double = 0.0
    @Published var priceChange: Double = 0.0
    @Published var percentageChange: Double = 0.0
    
    @Published var sharesOwned: Int = 0
    @Published var avgCostPerShare: Double = 0.0
    @Published var totalCost: Double = 0.0
    @Published var change: Double = 0.0
    @Published var marketValue: Double = 0.0
    var stockSymbol: String
    
    init(stockSymbol: String) {
        self.stockSymbol = stockSymbol
        fetchAllDetails()
    }
    
    private func fetchAllDetails() {
        fetchCompanyProfileDetails()
        fetchStockPriceDetails {
            self.fetchStockPortfolioDetails()
        }
        // Additional fetch methods for other parts of the detail view
    }
    
    private func fetchStockPriceDetails(completion: @escaping () -> Void) {
        NetworkService.fetchStockPriceDetails(for: stockSymbol) { [weak self] result in
            switch result {
            case .success(let details):
                self?.currentPrice = details.c
                self?.priceChange = details.d
                self?.percentageChange = details.dp
                completion()
            case .failure(let error):
                print("Error fetching stock details: \(error.localizedDescription)")
                completion()
            }
        }
    }
    
    private func fetchCompanyProfileDetails() {
        NetworkService.fetchCompanyProfile(for: stockSymbol) { result in
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self.companyName = profile.name
                    // update other properties as needed
                }
            case .failure(let error):
                print("Error fetching company profile: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchStockPortfolioDetails() {
        NetworkService.fetchStockPortfolio(for: stockSymbol) { [weak self] result in
            DispatchQueue.main.async {  // Ensure all UI updates are on the main thread.
                switch result {
                case .success(let portfolio):
                    self?.sharesOwned = portfolio.quantity
                    self?.avgCostPerShare = portfolio.averageCost
                    self?.totalCost = portfolio.totalCost
                    self?.marketValue = Double(self!.sharesOwned) * self!.currentPrice
                    self?.change = (self?.marketValue ?? 0.0) - (self?.totalCost ?? 0.0)
                case .failure(let error):
                    print("Error fetching portfolio details: \(error.localizedDescription)")
                    // Reset values if the stock is not found
                    self?.sharesOwned = 0
                    self?.avgCostPerShare = 0.0
                    self?.totalCost = 0.0
                    self?.marketValue = 0.0
                    self?.change = 0.0
                }
            }
        }
    }
    
}
