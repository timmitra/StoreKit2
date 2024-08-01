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
    @State var purchaseStart: Bool = false
    @StateObject var store: Store = Store()
    
    var body: some View {
        SubscriptionStoreView(groupID: "16C7A6B6", visibleRelationships: .all) {
            StoreContent()
                .containerBackground(Color.iTGuyLtBlue.gradient, for: .subscriptionStoreHeader)
        }
        .backgroundStyle(.clear)
        .subscriptionStorePickerItemBackground(.thinMaterial)
        .storeButton(.visible, for: .restorePurchases)
        .overlay {
            if purchaseStart {
                ProgressView().controlSize(.extraLarge)
            }
        }
        .onInAppPurchaseStart { product in
            print("User has started buying \(product.id)")
            purchaseStart.toggle()
        }
        .onInAppPurchaseCompletion { product, result in
            purchaseStart.toggle()
            Task {
                await store.updateCustomerProductStatus()
                await updateSubscriptionStatus()
            }
            if case .success(.success(let transaction)) = result {
                print("Purchased successfully: \(transaction.signedDate)")
              // update app storage
              subscribed = true
            } else {
                print("Something else happened")
            }
        }
        .sheet(isPresented: $lifetimePage) {
          LifetimeStoreView()
            .presentationDetents([.height(250)])
            .presentationBackground(.ultraThinMaterial)
        }
        Button("More Purchase Options", action: {
          lifetimePage = true
        })
    }
    
    @MainActor
    func updateSubscriptionStatus() async {
        if store.subscriptionGroupStatus == .subscribed
        || store.subscriptionGroupStatus == .inGracePeriod
            || store.purchasedLifetime {
            subscribed = true
        } else {
            subscribed = false
        }
    }
}

#Preview {
    ContentView()
}
