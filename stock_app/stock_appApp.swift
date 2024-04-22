//
//  stock_appApp.swift
//  stock_app
//
//  Created by Brian Li on 4/9/24.
//

import SwiftUI

@main
struct stock_appApp: App {
    @StateObject private var viewModel = AppViewModel()  // Initialize the view model

        var body: some Scene {
            WindowGroup {
                if viewModel.isLoading {
                    LoadingView()
                } else {
                    ContentView()
                }
            }
        }
}
