//
//  LifetimeView.swift
//  MyCloset
//
//  Created by Tim Mitra on 2024-07-30.
//  Copyright © 2024 iT Guy Technologies. All rights reserved.
//

import SwiftUI
import StoreKit

struct LifetimeStoreView: View {
  @AppStorage("isSubscribed") private var isSubscribed = false
  @Environment(\.dismiss) private var dismiss
  
    var body: some View {
      Image("ios-marketing")
        .resizable()
        .scaledToFit()
        .clipShape(RoundedRectangle(cornerRadius: 20.0))
        .frame(width: 100)
        .padding(.top, 20)
      //StoreView(ids: ["ITG.MyCloset.Lifetime"])
      ProductView(id:
        "lifetime_subscription"
      )
      .padding()
      #if !os(visionOS)
      .productViewStyle(.large)
      #endif
        .background(.ultraThinMaterial)
        .onInAppPurchaseStart { product in
            print("User has started buying \(product.id)")
        }
        .onInAppPurchaseCompletion { product, result in
            if case .success(.success(let transaction)) = result {
                print("Purchased successfully: \(transaction.signedDate)")
              // update app storage
                isSubscribed = true
              dismiss()
            } else {
                print("Something else happened")
            }
        }
    }
}

#Preview {
    LifetimeStoreView()
}
