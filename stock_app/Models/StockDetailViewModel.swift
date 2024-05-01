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
    
    @Published var highPrice: Double = 0.0
    @Published var lowPrice: Double = 0.0
    @Published var openPrice: Double = 0.0
    @Published var prevClosePrice: Double = 0.0
    
    @Published var ipoDateFormatted: String = ""
    @Published var industry: String = ""
    @Published var webURL: String = ""
    @Published var companyPeers: [String] = []
    
    @Published var totalMspChange: Double = 0
    @Published var positiveMspChange: Double = 0
    @Published var negativeMspChange: Double = 0
    @Published var totalChange: Double = 0
    @Published var positiveChange: Double = 0
    @Published var negativeChange: Double = 0
    
    @Published var newsArticles: [NewsArticle] = []
    
    @Published var summaryChartData: [[String: Any]] = []
    @Published var historicalChartData: [[String: Any]] = []

    @Published var isLoading = false
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
        fetchPeers()
        fetchInsiderSentiments()
        fetchNewsData()
        fetchSummaryChartData()
        fetchHistoricalChartData()
        // Additional fetch methods for other parts of the detail view
    }
    
    private func fetchStockPriceDetails(completion: @escaping () -> Void) {
        NetworkService.fetchStockPriceDetails(for: stockSymbol) { [weak self] result in
            switch result {
            case .success(let details):
                self?.currentPrice = details.c
                self?.priceChange = details.d
                self?.percentageChange = details.dp
                self?.highPrice = details.h
                self?.lowPrice = details.l
                self?.openPrice = details.o
                self?.prevClosePrice = details.pc
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
                    self.ipoDateFormatted = profile.ipo
                    self.industry = profile.finnhubIndustry
                    self.webURL = profile.weburl
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
    
    private func fetchPeers() {
        NetworkService.fetchCompanyPeers(for: stockSymbol) { [weak self] result in
            switch result {
            case .success(let peers):
                self?.companyPeers = peers
            case .failure(let error):
                print("Error fetching company peers: \(error.localizedDescription)")
                self?.companyPeers = []  // Optionally handle error state
            }
        }
    }
    
    private func fetchInsiderSentiments() {
        NetworkService.fetchInsiderData(for: stockSymbol) { result in
            switch result {
            case .success(let data):
                self.processInsiderData(data)
            case .failure(let error):
                print("Error fetching insider data: \(error.localizedDescription)")
            }
        }
    }
    
    private func processInsiderData(_ data: [InsiderData]) {
        let totalMsp = data.reduce(0.0) { $0 + $1.mspr }
        let positiveMsp = data.filter { $0.mspr > 0 }.reduce(0.0) { $0 + $1.mspr }
        let negativeMsp = data.filter { $0.mspr < 0 }.reduce(0.0) { $0 + $1.mspr }
        
        let totalChange = data.reduce(0.0) { $0 + $1.change }
        let positiveChange = data.filter { $0.change > 0 }.reduce(0.0) { $0 + $1.change }
        let negativeChange = data.filter { $0.change < 0 }.reduce(0.0) { $0 + $1.change }
        
        DispatchQueue.main.async {
            self.totalMspChange = totalMsp
            self.positiveMspChange = positiveMsp
            self.negativeMspChange = negativeMsp
            
            self.totalChange = totalChange
            self.positiveChange = positiveChange
            self.negativeChange = negativeChange
        }
    }
    
    private func fetchNewsData() {
        NetworkService.fetchNewsData(for: stockSymbol) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let articles):
                    self?.newsArticles = articles
                case .failure(let error):
                    print("Error fetching news data: \(error.localizedDescription)")
                    self?.newsArticles = []  // Optionally handle error state
                }
            }
        }
    }
    
    private func fetchSummaryChartData() {
        isLoading = true
        NetworkService.fetchSummaryChartData(for: stockSymbol) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let data):
                    self?.summaryChartData = data
                case .failure(let error):
                    print("Error fetching chart data: \(error)")
                }
            }
        }
    }
    
    private func fetchHistoricalChartData() {
            isLoading = true
            NetworkService.fetchHistoricalChartData(for: stockSymbol) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let data):
                        self?.historicalChartData = data
                    case .failure(let error):
                        print("Error fetching historical chart data: \(error.localizedDescription)")
                        self?.historicalChartData = []  // Optionally handle error state
                    }
                }
            }
        }
}
