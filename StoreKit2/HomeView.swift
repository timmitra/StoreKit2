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
import StoreKit

struct HomeView: View {
    @AppStorage("isSubscribed") private var isSubscribed: Bool = false
    @State private var showStoreView: Bool = false
    @State private var showNewView: Bool = false
    @EnvironmentObject private var store: Store

    var body: some View {
        ZStack {
            VStack {
                Text(isSubscribed ? "Thanks" : "Choose a plan.")
                    .font(.largeTitle.bold())
                Text(isSubscribed ? "You are subscribed" : "A purchase is required to use this app.")
                Image("ios-marketing")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
                    .frame(width: 100)
                
                if store.purchasedSubscriptions.isEmpty {
                    
                    Button("Show Store") {
                        showStoreView = true
                    }
                }
                
                if (isSubscribed == true) {
                    let _ = print("isSubscribed value: \(isSubscribed)")
                    Button("New View") {
                        showNewView = true
                    }
                } else {
                    Button("Show Store") {
                        showStoreView = true
                    }
                }
            }
            .onAppear {
                printAppStorageValue()
                Task {
                    await store.updateCustomerProductStatus()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                Task {
                    await store.updateCustomerProductStatus()
                }
            }
            .sheet(isPresented: $showStoreView, content: {
                StoreView()
                         })
            .sheet(isPresented: $showNewView, content: {
                             NewView()
                                      })
        }
    }
    // Function to print the AppStorage value
    func printAppStorageValue() {
        print("HomeView - AppStorage 'isSubscribed' value: \(isSubscribed)")
    }
    func setFalse() {
        isSubscribed = false
    }
}

#Preview {
    HomeView()
}
