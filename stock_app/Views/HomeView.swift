//
//  HomeView.swift
//  stock_app
//
//  Created by Brian Li on 4/18/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = AutocompleteViewModel()
    @StateObject private var portfolioViewModel = PortfolioViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    let finnhubURL = URL(string: "https://finnhub.io")
    
    var todaysDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
    
    var body: some View {
            NavigationView {
                ZStack {
                    if !viewModel.searchText.isEmpty && !viewModel.suggestions.isEmpty {
                        AutocompleteListView(viewModel: viewModel)
                    } else {
                        listContent
                    }
                }
                .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
                .navigationTitle("Stocks")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
        }

        var listContent: some View {
            List {
                Section {
                    Text(todaysDate)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 5.0)
                
                Section(header: Text("Portfolio")) {
                    PortfolioView(viewModel: portfolioViewModel)
                }
                
                Section(header: Text("Favorites")) {
                    FavoritesView(viewModel: favoritesViewModel)
                }
                
                Section {
                    Text("Powered by Finnhub.io")
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture{
                            openURL(finnhubURL)
                        }
                }
            }
        }
    func openURL(_ url: URL?) {
            guard let url = url, UIApplication.shared.canOpenURL(url) else {
                print("Invalid URL")
                return
            }
            UIApplication.shared.open(url)
        }
}


#Preview {
    HomeView()
}
