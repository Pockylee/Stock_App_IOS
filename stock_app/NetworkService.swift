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
    
    static func fetchCompanyProfile(for symbol: String, completion: @escaping (Result<CompanyProfile, Error>) -> Void) {
        let urlString = "\(APIConfig.baseURL)/profile/\(symbol)"
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
                let companyProfile = try JSONDecoder().decode(CompanyProfile.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(companyProfile))
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
    
    static func fetchStockPortfolio(for symbol: String, completion: @escaping (Result<StockPortfolio, Error>) -> Void) {
        let url = URL(string: "\(APIConfig.baseURL)/portfolio")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            do {
                let items = try JSONDecoder().decode([StockPortfolio].self, from: data)
                if let item = items.first(where: { $0.symbol == symbol }) {
                    completion(.success(item))
                } else {
                    completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Symbol not found"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    static func fetchCompanyPeers(for symbol: String, completion: @escaping (Result<[String], Error>) -> Void) {
            let urlString = "\(APIConfig.baseURL)/peers/\(symbol)"
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
                    let peers = try JSONDecoder().decode([String].self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(peers))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
    
    static func fetchInsiderData(for symbol: String, completion: @escaping (Result<[InsiderData], Error>) -> Void) {
        let urlString = "\(APIConfig.baseURL)/insider/\(symbol)"
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
                let response = try JSONDecoder().decode(InsiderResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(response.data))
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
    
    static func fetchNewsData(for symbol: String, completion: @escaping (Result<[NewsArticle], Error>) -> Void) {
            let urlString = "\(APIConfig.baseURL)/news/\(symbol)"
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
                    let newsArticles = try JSONDecoder().decode([NewsArticle].self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(newsArticles))
                    }
                } catch {
                    print("JSON Decoding error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
    
    static func fetchSummaryChartData(for symbol: String, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
            let urlString = "\(APIConfig.baseURL)/summarychart/\(symbol)"
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(error ?? NSError(domain: "", code: -2, userInfo: nil)))
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let results = json["results"] as? [[String: Any]] {
                        completion(.success(results))
                    } else {
                        completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            }

            task.resume()
        }
    
    static func fetchHistoricalChartData(for symbol: String, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
            let urlString = "\(APIConfig.baseURL)/historicalchart/\(symbol)"
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard error == nil else {
                    completion(.failure(error!))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }

                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let results = jsonArray["results"] as? [[String: Any]] {
                        completion(.success(results))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
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

struct CompanyProfile: Decodable {
    let country: String
    let currency: String
    let estimateCurrency: String
    let exchange: String
    let finnhubIndustry: String
    let ipo: String
    let logo: String
    let marketCapitalization: Double
    let name: String
    let phone: String
    let shareOutstanding: Double
    let ticker: String
    let weburl: String
}

struct StockPortfolio: Decodable {
    let symbol: String
    let companyName: String
    let quantity: Int
    let totalCost: Double
    let averageCost: Double
}

struct InsiderData: Decodable {
    var symbol: String
    var year: Int
    var month: Int
    var change: Double
    var mspr: Double
}

struct InsiderResponse: Decodable {
    var data: [InsiderData]
    var symbol: String
}

struct NewsArticle: Identifiable, Decodable {
    let id: Int
    let category: String
    let datetime: Int
    let headline: String
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}
