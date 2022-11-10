//
//  FinancialConnectionsPartnerAccount.swift
//  StripeFinancialConnections
//
//  Created by Krisjanis Gaidis on 10/27/22.
//  Copyright © 2022 Stripe, Inc. All rights reserved.
//

import Foundation

struct FinancialConnectionsPartnerAccount: Decodable {
    let id: String
    let name: String
    let displayableAccountNumbers: String?
    let linkedAccountId: String? // determines whether we show a "Linked" label
    let balanceAmount: Double?
    let currency: String?
    let supportedPaymentMethodTypes: [FinancialConnectionsPaymentMethodType]
    let allowSelection: Bool
    let allowSelectionMessage: String?
    
    var balanceInfo: (balanceAmount: Double, currency: String)? {
        if let balanceAmount = balanceAmount, let currency = currency {
            return (balanceAmount, currency)
        } else {
            return nil
        }
    }
}

struct FinancialConnectionsDisabledPartnerAccount {
    let account: FinancialConnectionsPartnerAccount
    let disableReason: String
}

struct FinancialConnectionsAuthorizationSessionAccounts: Decodable {
    let data: [FinancialConnectionsPartnerAccount]
    let nextPane: FinancialConnectionsSessionManifest.NextPane
}
