//
//  TradeSheetView.swift
//  stock_app
//
//  Created by Brian Li on 5/2/24.
//

import SwiftUI

struct TradeSheetView: View {
    @ObservedObject var viewModel: StockDetailViewModel
    @ObservedObject var portfolioViewModel: PortfolioViewModel
    
    @State private var numberOfShares: String = ""
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var showingSuccessView = false
    @State private var successMessage: String = ""
    
    
    var body: some View {
        VStack {
            
            Text("Trade \(viewModel.companyName) shares")
                .padding(.top)
            Spacer()
            
            HStack {
                TextField("0", text: $numberOfShares)
                    .keyboardType(.numberPad)
                    .font(.system(size: 90))
                    .padding()
                Text(numberOfSharesAsInt <= 1 ? "Share" : "Shares")
                    .font(.largeTitle)
            }
            
            
            HStack {
                Spacer()
                Text("x $\(viewModel.currentPrice, specifier: "%.2f")/share = \(totalCost, specifier: "$%.2f")")
                    .font(.body)
            }
            
            Spacer()
            
            VStack {
                if showingToast {
                    Text(toastMessage)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .transition(.slide)
                        .cornerRadius(30) // Apply a corner radius to the
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showingToast = false
                                }
                            }
                        }
                }
                Text("\(portfolioViewModel.cashBalance, specifier: "$%.2f") available to buy \(viewModel.stockSymbol)")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            
            
            
            HStack {
                Button("Buy") {
                    attemptToBuyShares()
                    // Implement the buy action
                }
                .padding(.horizontal, 60)
                .padding(.vertical, 15)
                .background(Color.green)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                
                Button("Sell") {
                    attemptToSellShares()
                    // Implement the sell action
                }
                .padding(.horizontal, 60)
                .padding(.vertical, 15)
                .background(Color.green)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 30))
            }
            .padding(.vertical)
        }
        .overlay(
            successView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.green)
                .edgesIgnoringSafeArea(.all)
                .opacity(showingSuccessView ? 1 : 0)
                .animation(.easeInOut, value: showingSuccessView)
        )
        .onTapGesture {
            self.hideKeyboard()
        }
    }
    
    private var successView: some View {
        VStack {
            Spacer()
            Text("Congratulations!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
            Text(successMessage)
                .foregroundColor(.white)
                .padding()
            Spacer()
            Button("Done") {
                showingSuccessView = false
            }
            .padding(.horizontal, 150)
            .padding(.vertical, 15)
            .background(Color.white)
            .foregroundColor(.green)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding(.bottom, 50) // Adds padding at the bottom
            
        }
    }
    
    private var numberOfSharesAsInt: Int {
        return Int(numberOfShares) ?? 0
    }
    
    private var totalCost: Double {
        return Double(numberOfSharesAsInt) * viewModel.currentPrice
    }
    
    private func attemptToBuyShares() {
        if let shares = Int(numberOfShares), shares > 0 {
            if Double(shares) * viewModel.currentPrice <= portfolioViewModel.cashBalance {
                sendBuyRequest(shares: shares, totalCost: totalCost)
                let change = -totalCost
                updateWallet(change: change) {
                    portfolioViewModel.cashBalance += change
                }
                
            } else {
                showToast(message: "Not enough money to buy")
            }
        } else {
            showToast(message: "Cannot buy non-positive shares")
        }
    }
    
    private func attemptToSellShares() {
        if let shares = Int(numberOfShares), shares > 0 {
            if shares <= viewModel.sharesOwned {
                
                sendSellRequest(shares: shares, totalCost: totalCost)
                let change = totalCost
                updateWallet(change: change) {
                    portfolioViewModel.cashBalance += change
                }
            } else {
                showToast(message: "Not enough shares to sell")
            }
        } else {
            showToast(message: "Cannot sell non-positive shares")
        }
    }
    
    private func showToast(message: String) {
        toastMessage = message
        showingToast = true
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func sendSellRequest(shares: Int, totalCost: Double) {
        let url = URL(string: "\(APIConfig.baseURL)/portfolio/sell")! // Change to your actual server URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "symbol": viewModel.stockSymbol,
            "companyName": viewModel.companyName,
            "quantity": shares,
            "totalCost": totalCost
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Error: cannot create JSON from requestBody")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.showToast(message: "Failed to sell shares due to wallet database connect problem")
                }
                return
            }
            
            if let jsonData = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(PortfolioEntry.self, from: jsonData)
                    DispatchQueue.main.async {
                        self.viewModel.sharesOwned -= shares // Update local viewModel with new shares count
                        self.successMessage = "You have successfully sold \(shares) \(shares == 1 ? "share" : "shares") of \(self.viewModel.stockSymbol)"
                        self.showingSuccessView = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showToast(message: "Error decoding response")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showToast(message: "No data received from server")
                }
            }
        }.resume()
    }
    
    private func sendBuyRequest(shares: Int, totalCost: Double) {
        let url = URL(string: "\(APIConfig.baseURL)/portfolio")! // Change to your actual server URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "symbol": viewModel.stockSymbol,
            "companyName": viewModel.companyName,
            "quantity": shares,
            "totalCost": totalCost
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Error: cannot create JSON from requestBody")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.showToast(message: "Failed to buy shares due to wallet database connect problem")
                }
                return
            }
            
            if let jsonData = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(PortfolioEntry.self, from: jsonData)
                    DispatchQueue.main.async {
                        self.viewModel.sharesOwned += shares // Update local viewModel with new shares count
                        self.successMessage = "You have successfully bought \(shares) \(shares == 1 ? "share" : "shares") of \(self.viewModel.stockSymbol)"
                        self.showingSuccessView = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showToast(message: "Error decoding response")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showToast(message: "No data received from server")
                }
            }
        }.resume()
    }
    
    private func updateWallet(change: Double, completion: @escaping () -> Void) {
        let url = URL(string: "\(APIConfig.baseURL)/wallet")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody: [String: Any] = ["change": change]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Error: cannot create JSON from requestBody")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    showToast(message: "Failed to update wallet")
                }
                return
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }.resume()
    }
}


struct PortfolioEntry: Decodable {
    var symbol: String
    var quantity: Int
    var totalCost: Double
    var averageCost: Double? // Include other fields as per your API response
}

#Preview {
    TradeSheetView(viewModel: StockDetailViewModel(stockSymbol: "AAPL"), portfolioViewModel: PortfolioViewModel())
}
