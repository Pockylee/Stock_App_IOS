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
            
            
            if showingToast {
                Text(toastMessage)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .transition(.slide)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showingToast = false
                            }
                        }
                    }
            }
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
                // Execute the buy transaction
                successMessage = "You have successfully sold \(numberOfShares) \(numberOfSharesAsInt == 1 ? "share" : "shares") of \(viewModel.stockSymbol)"
                showingSuccessView = true
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
                // Execute the sell transaction
                successMessage = "You have successfully bought \(numberOfShares) \(numberOfSharesAsInt == 1 ? "share" : "shares") of \(viewModel.stockSymbol)"
                showingSuccessView = true
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
    
    
}

#Preview {
    TradeSheetView(viewModel: StockDetailViewModel(stockSymbol: "AAPL"), portfolioViewModel: PortfolioViewModel())
}
