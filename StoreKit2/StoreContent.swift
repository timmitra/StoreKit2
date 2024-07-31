//
// ---------------------------- //
// Original Project: StoreKit2
// Created on 2024-07-31 by Tim Mitra
// Mastodon: @timmitra@mastodon.social
// Twitter/X: timmitra@twitter.com
// Web site: https://www.it-guy.com
// ---------------------------- //
// Copyright © 2024 iT Guy Technologies. All rights reserved.


import SwiftUI

struct StoreContent: View {
    @AppStorage("subscribed") private var subscribed: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Text(subscribed ? "Thanks" : "Choose a plan.")
                    .font(.largeTitle.bold())
                Text(subscribed ? "You are subscribed" : "A purchase is required to use this app.")
                Image("ios-marketing")
                  .resizable()
                  .scaledToFit()
                  .clipShape(RoundedRectangle(cornerRadius: 20.0))
                  .frame(width: 100)
            }
        }
    }
}

#Preview {
    StoreContent()
}
