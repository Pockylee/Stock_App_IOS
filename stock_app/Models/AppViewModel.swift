//
//  AppViewModel.swift
//  stock_app
//
//  Created by Brian Li on 4/20/24.
//
import Combine
import Dispatch

class AppViewModel: ObservableObject {
    @Published var isLoading = true

    init() {
        loadData()
    }
    
    func loadData() {
        // Simulate network or other load with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {  // Adjust delay as needed
            self.isLoading = false  // Set to false to switch view
        }
    }
}
