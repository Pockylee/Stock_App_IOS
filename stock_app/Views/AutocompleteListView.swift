//
//  AutocompleteListView.swift
//  stock_app
//
//  Created by Brian Li on 4/19/24.
//

import SwiftUI

struct AutocompleteListView: View {
    @ObservedObject var viewModel: AutocompleteViewModel
    
    var body: some View {

            List(viewModel.suggestions, id: \.self) { suggestion in
                NavigationLink(destination: StockDetailView(stockSymbol: suggestion.symbol)){
                    VStack(alignment: .leading) {
                        Text(suggestion.symbol)
                            .font(.headline)
                            .fontWeight(.black)
                            .multilineTextAlignment(.leading)
                        
                        Text(suggestion.description)
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                    }
                }
                .onTapGesture {
                    viewModel.selectSuggestion(suggestion)
                    // Perform additional actions if needed
                }
            }
        
    }
}

//#Preview {
//    AutocompleteListView(viewModel: viewModel)
//}

struct AutocompleteListView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an instance of the view model
        let viewModel = AutocompleteViewModel()
        // Return the view with the populated view model
        return AutocompleteListView(viewModel: viewModel)
    }
}
