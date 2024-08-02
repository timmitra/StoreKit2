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

struct NewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showSubscriptions = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to NewView!")
                Button("Manage Suscriptions") {
                    showSubscriptions = true
                }
            }
                .navigationTitle("NewView")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
                .manageSubscriptionsSheet(isPresented: $showSubscriptions)
        }
    }
}

#Preview {
    NewView()
}
