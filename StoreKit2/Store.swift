//
// ---------------------------- //
// Original Project: StoreKit2
// Created on 2024-07-31 by Tim Mitra
// Mastodon: @timmitra@mastodon.social
// Twitter/X: timmitra@twitter.com
// Web site: https://www.it-guy.com
// ---------------------------- //
// Copyright © 2024 iT Guy Technologies. All rights reserved.


import Foundation
import StoreKit

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error {
     case failedVerification
}

public enum SubscriptionTier: Int, Comparable {
    case none = 0
    case monthly = 1
    case yearly = 2
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

class Store: ObservableObject {
    @Published private(set) var lifetime: [Product]
    @Published private(set) var subscriptions: [Product]
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var purchasedLifetime: Bool = false
    @Published private(set) var subscriptionGroupStatus: RenewalState? = .none
    
    var updateListenerTask: Task<Void, Error>? = nil
    private let productIDs: [String: String]
    
    init() {
        productIDs = Store.loadProductIdData()
        
        subscriptions = []
        lifetime = []
        
        updateListenerTask = listenForTransactions()
        
        Task {
            await requestProducts()
            
            await updateCustomerProductStatus()
            
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    static func loadProductIdData() -> [String: String] {
        guard let path = Bundle.main.path(forResource: "SampleStore", ofType: "plist "),
              let plist = FileManager.default.contents(atPath: path),
              let data = try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String: String]
        else { return [:] }
        return data
    }
    
    //MARK: LISTENER
    ///This functionality is responsible for listening for updates on App Store Connect or a local StoreKit file,
    ///which could occur on devices separate from the one you're on
    ///(i.e. if a family member upgrades to a family plan or when a guardian or bank approves a pending purchase,
    ///the app will listen for that update and automatically update your availability).
    func listenForTransactions() -> Task<Void, Error> {
      return Task.detached {
          ///Iterate through any transactions that don't come from a direct call to `purchase()`.
        for await result in Transaction.updates {
          do {
            let transaction = try self.checkVerified(result)
              print("Verified transaction: \(transaction.id) for product: \(transaction.productID)")
              ///Deliver products to the user.
            await self.updateCustomerProductStatus()
              ///Always finish a transaction.
            await transaction.finish()
          } catch {
              ///StoreKit has a transaction that fails verification. Don't deliver content to the user.
            print("Transaction failed verification: \(error)")
          }
        }
      }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        ///Check whether the JWS passes StoreKit verification.
      switch result {
          ///StoreKit parses the JWS, but it fails verification.
      case .unverified:
        throw StoreError.failedVerification
          ///The result is verified. Return the unwrapped value.
      case .verified(let safe):
        return safe
      }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedSubscriptions: [Product] = []
        //var purchasedLifetime: [Product] = []
        
        ///Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.id == 0 {
                    print("no transaction")
                }
                switch transaction.productType {
                case .nonConsumable:
                    purchasedLifetime = true
                    print("isSubscribed: lifetime")
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                        purchasedSubscriptions.append(subscription)
                        print("isSubscribed: \(subscription)")
                    }
                default:
                    break
                }
            } catch {
                print("Could not verify transaction: \(error)")
            }
        }
        //Update the Store information with the purchased products.
        self.purchasedSubscriptions = purchasedSubscriptions
        self.purchasedLifetime = purchasedLifetime
        
        //Check subscriptionGroupStatus to learn auto-renewable subscription state
        subscriptionGroupStatus = try? await subscriptions.first?.subscription?.status.first?.state

        await updateAppStorage()
    }
    
    @MainActor
    func updateAppStorage() async {
        if subscriptionGroupStatus == .expired {
            UserDefaults.standard.set(false, forKey: "isSubscribed")
        }
        print("AppStorage 'isSubscribed' updated to: \(UserDefaults.standard.bool(forKey: "isSubscribed"))")
    }
    
    @MainActor
    func requestProducts() async {
        do {
            let storeProducts = try await Product.products(for: productIDs.keys)
            
            var newLifetime: [Product] = []
            var newSubscriptions: [Product] = []
            
            for product in storeProducts {
                switch product.type {
                case .nonConsumable:
                    newLifetime.append(product)
                case .autoRenewable:
                    newSubscriptions.append(product)
                default:
                    print("Unknown product type: \(product.type)")
                }
            }
            lifetime = sortByPrice(newLifetime)
            subscriptions = sortByPrice(newSubscriptions)
            
            // Debugging
            print("Fetched \(newLifetime.count) lifetime products")
            print("Fetched \(newSubscriptions.count) subscription products")
        } catch {
            print("Failed to request products from the App Store server: \(error)")
        }
    }
    
    func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price < $1.price })
    }
    
    func tier(for productId: String) -> SubscriptionTier {
        switch productId {
        case "monthly_subscription":
            return .monthly
        case "yearly_subscription":
            return .yearly
        default:
            return .none
        }
    }
    
    func isPurchased(_ product: Product) async throws -> Bool {
        switch product.type {
        case .nonConsumable:
            return purchasedLifetime
        case .autoRenewable:
            return purchasedSubscriptions.contains(product)
        default:
            return false
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            await updateCustomerProductStatus()
            
            await transaction.finish()
            
            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }
}
