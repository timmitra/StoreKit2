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

struct StoreView: View {
    @AppStorage("isSubscribed") private var isSubscribed: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var lifetimePage: Bool = false
    @State var purchaseStart: Bool = false
    @StateObject var store: Store = Store()
    
    var body: some View {
        SubscriptionStoreView(groupID: "21520171", visibleRelationships: .all) {
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
            }
            if case .success(.success(let transaction)) = result {
                print("Purchased successfully: \(transaction.signedDate)")
                // update app storage
                isSubscribed = true
                print("StoreView - AppStorage 'isSubscribed' value: \(isSubscribed)")
            } else {
                print("Something else happened")
            }
            dismiss()
        }
        .onAppear {
            printAppStorageValue()
            Task {
                //When this view appears, get the latest subscription status.
                await store.updateCustomerProductStatus()
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
        .onChange(of: isSubscribed) { oldValue, newValue in
            print("1. isSubscribed changed from \(oldValue) to \(newValue)")
        }
        .onChange(of: store.purchasedSubscriptions) { _, _ in
            Task {
                await store.updateCustomerProductStatus()
            }
        }
        .onChange(of: store.purchasedLifetime) { _, _ in
            Task {
                await store.updateCustomerProductStatus()
            }
        }
    }
        
    // not used any more
    @MainActor
    func updateSubscriptionStatus() async {
        print("Updating subscription status...")
        print("Current subscription group status: \(String(describing: store.subscriptionGroupStatus))")
        print("Purchased lifetime: \(store.purchasedLifetime)")
        
        if store.subscriptionGroupStatus == .subscribed
            || store.subscriptionGroupStatus == .inGracePeriod
            || store.purchasedLifetime {
            // update AppStorage
            isSubscribed = true
            print("1. Subscription is active. Setting isSubscribed to true.")
        } else if store.subscriptionGroupStatus == .expired {
            isSubscribed = false
            print("2. Subscription expired. Setting isSubscribed to false.")
        } else {
            // commented out because it's wrong
            // isSubscribed = false
            print("3. Subscription is not active. Setting isSubscribed to ...")
        }
        self.printAppStorageValue()
    }
    
    // Function to print the AppStorage value
    func printAppStorageValue() {
        print("AppStorage 'isSubscribed' value: \(isSubscribed)")
    }
}

#Preview {
    StoreView()
}

extension StoreView {
    func restorePurchases() {
        Task {
            await store.updateCustomerProductStatus()
        }
    }
}
