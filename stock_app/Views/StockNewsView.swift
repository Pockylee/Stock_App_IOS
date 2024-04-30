//
//  StockNewsView.swift
//  stock_app
//
//  Created by Brian Li on 4/30/24.
//

import SwiftUI

struct StockNewsView: View {
    var body: some View {
        VStack() {
            Text("News")
                .font(.title2)
                .fontWeight(.medium)
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    StockNewsView()
}
