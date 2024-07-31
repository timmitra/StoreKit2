//
// --------------------------------------------
// Original Project: StoreKit2
// Created on 2024-07-31 by Tim Mitra
// Mastodon: @timmitra@mastodon.social
// Twitter/X: timmitra@twitter.com
// Web site: https://www.it-guy.com
// --------------------------------------------
// Copyright © 2024 iT Guy Technologies. All rights reserved.


import SwiftUI
import StoreKit

struct ContentView: View {
    @AppStorage("subscribed") private var subscribed: Bool = false
    @State private var lifetimePage: Bool = false
    
    var body: some View {
        SubscriptionStoreView(groupID: "16C7A6B6", visibleRelationships: .all) {
            StoreContent()
                .containerBackground(Color.iTGuyLtBlue.gradient, for: .subscriptionStoreHeader)
        }
        .backgroundStyle(.clear)
        .subscriptionStorePickerItemBackground(.thinMaterial)
        .storeButton(.visible, for: .restorePurchases)
        .sheet(isPresented: $lifetimePage) {
          LifetimeStoreView()
            .presentationDetents([.height(250)])
            .presentationBackground(.ultraThinMaterial)
        }
        Button("More Purchase Options", action: {
          lifetimePage = true
        })
    }
}

#Preview {
    ContentView()
}
