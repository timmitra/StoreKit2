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
    @AppStorage("subscribed") private var subscribed: Bool = false
    @State private var showStoreView: Bool = false
    @State private var showNewView: Bool = false
    @StateObject var store: Store = Store()

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
                if (subscribed == true) {
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
        print("HomeView - AppStorage 'subscribed' value: \(subscribed)")
    }
}

#Preview {
    HomeView()
}
