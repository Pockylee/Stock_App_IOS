//
//  StockInsightsView.swift
//  stock_app
//
//  Created by Brian Li on 4/29/24.
//

import SwiftUI

struct StockInsightsView: View {
    var body: some View {
        VStack() {
            Text("Insights")
                .font(.title2)
                .fontWeight(.medium)
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .center){
                Text("Insider Sentiments")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.bottom, 5)
                HStack{
                    VStack(alignment: .leading, spacing: 10){
                        Text("Apple Inc")
                        Divider()
                        Text("Total")
                        Divider()
                        Text("Positive")
                        Divider()
                        Text("Negative")
                        Divider()
                    }
                    .fontWeight(.bold)
                    VStack(alignment: .leading, spacing: 10){
                        Text("MSPR")
                            .fontWeight(.bold)
                        Divider()
                        Text("Total")
                        Divider()
                        Text("Positive")
                        Divider()
                        Text("Negative")
                        Divider()
                    }
                    VStack(alignment: .leading, spacing: 10){
                        Text("Change")
                            .fontWeight(.bold)
                        Divider()
                        Text("Total")
                        Divider()
                        Text("Positive")
                        Divider()
                        Text("Negative")
                        Divider()
                    }
                    
                }
            }
            
        }
    }
}

#Preview {
    StockInsightsView()
}
