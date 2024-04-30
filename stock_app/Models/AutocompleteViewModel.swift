//
//  AutocompleteViewModel.swift
//  stock_app
//
//  Created by Brian Li on 4/19/24.
//

import Combine
import SwiftUI

class AutocompleteViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var suggestions: [AutocompleteItem] = []
    private var cancellables = Set<AnyCancellable>()
    
    private var useMockData = false
    
    init() {
        $searchText
            .removeDuplicates()
            .debounce(for: 0.3, scheduler: RunLoop.main)  // Avoid making too many requests
            .sink(receiveValue: loadAutocompleteSuggestions)
            .store(in: &cancellables)
    }
    
    private func loadAutocompleteSuggestions(for searchText: String) {
        
        if useMockData {
            let mockJSON = """
            [
                {
                    "symbol": "AAPL",
                    "description": "APPLE INC"
                },
                {
                    "symbol": "XAARF",
                    "description": "XAAR PLC"
                }
            ]
            """.data(using: .utf8)!
            
            do {
                let mockSuggestions = try JSONDecoder().decode([AutocompleteItem].self, from: mockJSON)
                self.suggestions = mockSuggestions
            } catch {
                print("Mock data decoding error:", error)
            }
        } else {
            guard !searchText.isEmpty else {
                self.suggestions = []
                return
            }
            let urlString = "http://127.0.0.1:8080/api/autocomplete/\(searchText)"
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .decode(type: [AutocompleteItem].self, decoder: JSONDecoder())  // Corrected to expect an array directly
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    // Your error handling...
                }, receiveValue: { [weak self] fetchedItems in
                    self?.suggestions = fetchedItems
                })
                .store(in: &cancellables)
        }
        
    }
    
    func selectSuggestion(_ suggestion: AutocompleteItem) {
        self.searchText = suggestion.symbol
    }
    
    
    
}

//struct AutocompleteResults: Decodable {
//    var result: [AutocompleteItem]
//}

struct AutocompleteItem: Decodable, Hashable {
    var symbol: String
    var description: String
}
