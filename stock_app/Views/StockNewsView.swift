//
//  StockNewsView.swift
//  stock_app
//
//  Created by Brian Li on 4/30/24.
//

import SwiftUI
import Kingfisher

struct StockNewsView: View {
    @ObservedObject var viewModel: StockDetailViewModel
    
    
    var body: some View {
        Text("News")
            .font(.title2)
            .fontWeight(.medium)
            .padding(.bottom, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
        VStack(alignment: .leading) {
            if let firstArticle = viewModel.newsArticles.first {
                NewsArticleView(article: firstArticle, isFeatured: true)
            }
            Divider()
            ForEach(viewModel.newsArticles.dropFirst()) { article in
                NewsArticleView(article: article)
            }
        }
    }
}

struct NewsArticleView: View {
    let article: NewsArticle
    var isFeatured: Bool = false
    @State private var showDetails = false
    
    var body: some View {
        if isFeatured {
            VStack(alignment: .leading) {
                KFImage(URL(string: article.image))
                    .resizable()
                //                           .aspectRatio(contentMode: .fill)
                    .clipped()
                    .cornerRadius(10)
                    .frame(height: 250)
                HStack {
                    Text(timeAgoSinceDate(unixTime: article.datetime))
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(article.source)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 2)
                Text(article.headline)
                    .font(.headline)
                    .bold()
                    .lineLimit(3)
                    .padding(.top, 2)
                //                           .padding(.bottom, 1)
            }
            .padding(.bottom, 10)
            .background(Color.white)
            .cornerRadius(10)
            .onTapGesture {
                showDetails = true
            }
            .sheet(isPresented: $showDetails) {
                NewsArticleDetailView(article: article)
            }
        } else {
            
            HStack {
                VStack (alignment: .leading){
                    HStack{
                        Text(timeAgoSinceDate(unixTime: article.datetime))
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(article.source)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 3)
                    Text(article.headline)
                        .font(.subheadline)
                        .bold()
                        .lineLimit(3)
                        .padding(.vertical, 2)
                }
                Spacer()
                KFImage(URL(string: article.image))
                    .resizable()
                //                            .aspectRatio(contentMode: .fill)
                    .clipped()
                    .cornerRadius(5)
                    .frame(width: 65, height: 75)
                
            }
            .onTapGesture {
                showDetails = true
            }
            .sheet(isPresented: $showDetails) {
                NewsArticleDetailView(article: article)
            }
        }
    }
    
    private func timeAgoSinceDate(unixTime: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated // Uses abbreviations like 'hr' for hour and 'min' for minute
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour, .minute], from: date, to: now)
        
        var result = ""
        if let hour = components.hour, hour > 0 {
            result = "\(hour) hr"
        }
        if let minute = components.minute, minute > 0 {
            if !result.isEmpty {
                result += ", "
            }
            result += "\(minute) min"
        }
        return result.isEmpty ? "Just now" : result
    }
}

#Preview {
    StockNewsView(viewModel: StockDetailViewModel(stockSymbol: "AAPL"))
}
