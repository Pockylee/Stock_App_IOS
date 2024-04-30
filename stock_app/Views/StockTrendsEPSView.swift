//
//  StockTrendsEPSView.swift
//  stock_app
//
//  Created by Brian Li on 4/30/24.
//

import SwiftUI

struct StockTrendsEPSView: View {
    var body: some View {
        VStack{
            Color.gray
                .frame(height: 300)
                .cornerRadius(10)
                .overlay(Text("Recommendation Trends Chart Placeholder").foregroundColor(.white))
            
            Color.gray
                .frame(height: 300)
                .cornerRadius(10)
                .overlay(Text("Historical   EPS Surprises Chart Placeholder").foregroundColor(.white))
        }
    }
}

#Preview {
    StockTrendsEPSView()
}
