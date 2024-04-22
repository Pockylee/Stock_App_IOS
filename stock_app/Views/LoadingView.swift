//
//  LoadingView.swift
//  stock_app
//
//  Created by Brian Li on 4/20/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
            VStack {
                Image("LoadingImage")  // Use your custom image name
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)  // Adjust size as needed
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)  // You can change the background color
            .edgesIgnoringSafeArea(.all)
        }
    }

#Preview {
    LoadingView()
}
