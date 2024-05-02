//
//  ChartsViewModel.swift
//  stock_app
//
//  Created by Brian Li on 5/2/24.
//

import Foundation


class HourlyChartViewModel: ObservableObject {
    
    @Published var data = HourlyChartData(timestamps: [], closes: [])
    @Published var isLoading = false
    
    var stockSymbol: String
    
    init(stockSymbol: String) {
        self.stockSymbol = stockSymbol
        fetchData()
    }
    
    func fetchData() {
        guard let url = URL(string: "\(APIConfig.baseURL)/summarychart/\(stockSymbol)") else {
            print("Invalid URL")
            return
        }
        
        isLoading = true
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let data = data, error == nil else {
                    print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                self?.parseData(data)
            }
        }
        task.resume()
    }
    
    private func parseData(_ data: Data) {
        do {
            let decodedResponse = try JSONDecoder().decode(SummaryChartResponse.self, from: data)
            var timestamps = [Int]()
            var closes = [Double]()
            
            for result in decodedResponse.results {
                timestamps.append(Int(result.t))
                closes.append(result.c)
            }
            
            self.data = HourlyChartData(timestamps: timestamps, closes: closes)
        } catch {
            print("Failed to decode JSON: \(error)")
        }
    }
}

// Define the necessary Codable structs to parse your JSON response
struct SummaryChartResponse: Codable {
    let results: [ChartResult]
}

struct ChartResult: Codable {
    let v: Int
    let vw: Double
    let o: Double
    let c: Double
    let h: Double
    let l: Double
    let t: Int
    let n: Int
}

struct HistoricalDataPoint: Codable {
    let v: Int      // Volume
    let o: Double   // Open price
    let h: Double   // High price
    let l: Double   // Low price
    let c: Double   // Close price
    let t: Int64    // Timestamp
}

// Define a structure to decode the API response
struct HistoricalResponse: Codable {
    let results: [HistoricalDataPoint]
}

// Define the model to hold parsed data for the view
struct HistoricalChartData {
    var timestamps: [Int64]
    var openPrices: [Double]
    var highPrices: [Double]
    var lowPrices: [Double]
    var closePrices: [Double]
    var volumes: [Int]
}

class HistoricalChartViewModel: ObservableObject {
    @Published var data = HistoricalChartData(timestamps: [], openPrices: [], highPrices: [], lowPrices: [], closePrices: [], volumes: [])
    @Published var isLoading = false
    var stockSymbol: String
    
    init(stockSymbol: String) {
        self.stockSymbol = stockSymbol
        fetchData()
    }
    
    // Function to fetch data from the server
    func fetchData() {
        guard let url = URL(string: "\(APIConfig.baseURL)/historicalchart/\(stockSymbol)") else {
            print("Invalid URL")
            return
        }
        
        isLoading = true
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let data = data, error == nil else {
                    print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                self?.parseData(data)
            }
        }.resume()
    }
    
    // Function to parse the JSON data
    private func parseData(_ data: Data) {
        do {
            let decodedResponse = try JSONDecoder().decode(HistoricalResponse.self, from: data)
            let timestamps = decodedResponse.results.map { $0.t }
            let opens = decodedResponse.results.map { $0.o }
            let highs = decodedResponse.results.map { $0.h }
            let lows = decodedResponse.results.map { $0.l }
            let closes = decodedResponse.results.map { $0.c }
            let volumes = decodedResponse.results.map { $0.v }
            
            self.data = HistoricalChartData(timestamps: timestamps, openPrices: opens, highPrices: highs, lowPrices: lows, closePrices: closes, volumes: volumes)
        } catch {
            print("Failed to decode JSON: \(error)")
        }
    }
}




import Foundation

class RecommendationChartViewModel: ObservableObject {
    @Published var recommendationData = [RecommendationData]()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var stockSymbol: String
    
    // Initialize with a stock symbol
    init(stockSymbol: String) {
        self.stockSymbol = stockSymbol
        fetchData()
    }
    
    // Fetch data from the API
    func fetchData() {
        guard let url = URL(string: "\(APIConfig.baseURL)/recommendation/\(stockSymbol)") else {
            errorMessage = "Invalid URL"
            print("Error: Invalid URL")
            return
        }
        
        isLoading = true
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Error fetching data: \(error.localizedDescription)"
                    print("Error during fetch: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    print("Error: No data received from the server")
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode([RecommendationData].self, from: data)
                    self?.recommendationData = decodedData
                    print("Data fetched and decoded successfully")
                } catch {
                    self?.errorMessage = "Error decoding data: \(error.localizedDescription)"
                    print("Error decoding data: \(error)")
                }
            }
        }.resume()
    }
}

struct RecommendationData: Codable {
    var buy: Int
    var hold: Int
    var sell: Int
    var strongBuy: Int
    var strongSell: Int
    var period: String
    var symbol: String
}

class EPSChartViewModel: ObservableObject {
    @Published var epsData = [EPSData]()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var stockSymbol: String
    
    // Initialize with a stock symbol
    init(stockSymbol: String) {
        self.stockSymbol = stockSymbol
        fetchData()
    }
    
    // Fetch data from the API
    func fetchData() {
        guard let url = URL(string: "\(APIConfig.baseURL)/earnings/\(stockSymbol)") else {
            errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Error fetching data: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode([EPSData].self, from: data)
                    self?.epsData = decodedData
                } catch {
                    self?.errorMessage = "Error decoding data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// Struct to match the JSON data format for EPS
struct EPSData: Codable {
    var actual: Double
    var estimate: Double
    var period: String
    var quarter: Int
    var surprise: Double
    var surprisePercent: Double
    var symbol: String
    var year: Int
}




struct HourlyChartData {
    var timestamps: [Int]
    var closes: [Double]
}






