//
//  NewsArticleDetailView.swift
//  stock_app
//
//  Created by Brian Li on 5/1/24.
//

import SwiftUI
import Kingfisher

struct NewsArticleDetailView: View {
    let article: NewsArticle
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(article.source)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(verbatim: formatDate(unixTime: article.datetime))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Divider()
                
                Text(article.headline)
                    .font(.title2)
                    .bold()
                
                Text(article.summary)
                    .font(.callout)
                
                HStack {
                    Text("For more details click")
                        .foregroundColor(Color.gray)
                    Text("here")
                        .foregroundColor(.blue)
                        .font(.caption.weight(.bold))
                        .onTapGesture {
                            if let url = URL(string: article.url), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }
                    
                }
                .font(.caption)
                
                HStack {
                    Button(action: {
                        shareOnTwitter(shareURL: article.url, content: article.headline)
                    }) {
                        Image("XIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40) // Adjust size as needed
                        
                    }
                    
                    Button(action: {
                        shareOnFacebook(shareURL: article.url)
                    }) {
                        Image("facebookIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40) // Adjust size as needed
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()                }
            }
        }
    }
    
    private func formatDate(unixTime: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func shareOnTwitter(shareURL: String, content: String) {
        openURL("https://twitter.com/intent/tweet?url=\(shareURL)&text=\(content)")
    }
    
    private func shareOnFacebook(shareURL: String) {
        openURL("https://www.facebook.com/sharer/sharer.php?u=\(shareURL)")
    }
    
    private func openURL(_ urlString: String) {
        if let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedURL) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    NewsArticleDetailView(article: NewsArticle(
        id: 1,
        category: "Technology",
        datetime: 1651363200, // Corresponds to some date-time
        headline: "20 Largest Companies in the World by Market Cap in 2024",
        image: "https://example.com/image.jpg",
        related: "AAPL",
        source: "Yahoo",
        summary: "This article provides a detailed overview of the top 20 companies by market cap in 2024, featuring key insights into the trends and movements within the global market.",
        url: "https://yahoo.com/news/largest-companies"
    ))
}
