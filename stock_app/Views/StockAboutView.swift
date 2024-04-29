//
//  StockAboutView.swift
//  stock_app
//
//  Created by Brian Li on 4/29/24.
//

import SwiftUI

struct StockAboutView: View {
    var ipoStartDate: Date = Date()
    var industry: String = "Technology"
    var webPage: URL = URL(string: "https://www.apple.com/")!
    var companyPeers: [String] = ["AAPL", "DELL", "SMCI", "HPQ", "HPE"]
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.title2)
                .fontWeight(.medium)
                .padding(.bottom, 5)
            
            HStack {
                // Titles VStack
                VStack(alignment: .leading, spacing: 7) {
                    Text("IPO Start Date:")
                    Text("Industry:")
                    Text("Webpage:")
                    Text("Company Peers:")
                }
                .frame(width: 150, alignment: .leading)
                .fontWeight(.medium)
                
                // Values VStack
                VStack(alignment: .leading, spacing: 7) {
                    Text(dateFormatter.string(from: ipoStartDate))
                    Text(industry)
                    Link("Website", destination: webPage)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 2) {
                            ForEach(companyPeers, id: \.self) { peer in
                                Text(peer)
                                    .foregroundColor(.blue)
                                if peer != companyPeers.last {
                                    Text(",")
                                        .foregroundColor(.blue) //
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    StockAboutView()
}
