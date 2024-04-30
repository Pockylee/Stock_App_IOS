//
//  NetworkService.swift
//  stock_app
//
//  Created by Brian Li on 4/30/24.
//

import Foundation


class NetworkService {
    static func fetchCashBalance(completion: @escaping (Double) -> Void) {
        let url = URL(string: "\(APIConfig.baseURL)/wallet")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let balance = json["balance"] as? Double {
                    DispatchQueue.main.async {
                        completion(balance)
                    }
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    static func fetchPortfolioItems(completion: @escaping ([StockItem]) -> Void) {
        let url = URL(string: "\(APIConfig.baseURL)/portfolio")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode([PortfolioAPIItem].self, from: data)
                let stockItems = decodedData.map { StockItem(
                    symbol: $0.symbol,
                    shares: $0.quantity,
                    currentValue: 0, // Placeholder until real value can be fetched
                    changeValue: 0, // Placeholder until real value can be fetched
                    changePercentage: 0, // Placeholder until real value can be fetched
                    isPositiveChange: false // Placeholder until real value can be fetched
                )}
                DispatchQueue.main.async {
                    completion(stockItems)
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    static func fetchFavoriteItems(completion: @escaping ([FavStockItem]) -> Void) {
        let url = URL(string: "\(APIConfig.baseURL)/watchlist")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode([FavoriteAPIItem].self, from: data)
                let favStockItems = decodedData.map { FavStockItem(
                    symbol: $0.symbol,
                    companyName: $0.companyName,
                    currentValue: 0, // Placeholder until real value can be fetched
                    changeValue: 0, // Placeholder until real value can be fetched
                    changePercentage: 0, // Placeholder until real value can be fetched
                    isPositiveChange: false // Placeholder until real value can be fetched
                )}
                DispatchQueue.main.async {
                    completion(favStockItems)
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
                
            }
        }
        task.resume()
    }
    
    static func fetchStockPriceDetails(for symbol: String, completion: @escaping (Result<StockPriceDetail, Error>) -> Void) {
        let urlString = "\(APIConfig.baseURL)/stock/\(symbol)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            do {
                let stockPriceDetail = try JSONDecoder().decode(StockPriceDetail.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(stockPriceDetail))
                }
            } catch {
                print("JSON Decoding error: \(error.localizedDescription)")
                print(String(data: data, encoding: .utf8) ?? "Invalid UTF-8 data")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}


struct StockPriceDetail: Decodable {
    let c: Double  // Current price
    let d: Double  // Change in price
    let dp: Double // Change percentage
    let h: Double  // High price
    let l: Double  // Low price
    let o: Double  // Open price
    let pc: Double // Previous close price
    let t: Int     // Timestamp
}
