//
//  LinkSignupViewModel.swift
//  StripeiOS
//
//  Created by Ramon Torres on 1/19/22.
//  Copyright © 2022 Stripe, Inc. All rights reserved.
//

import Foundation
@_spi(STP) import StripeUICore

protocol LinkSignupViewModelDelegate: AnyObject {
    func signupViewModelDidUpdate(_ viewModel: LinkSignupViewModel)
}

final class LinkSignupViewModel {

    weak var delegate: LinkSignupViewModelDelegate?

    private let accountService: LinkAccountServiceProtocol

    private let accountLookupDebouncer = OperationDebouncer(debounceTime: .milliseconds(500))

    let merchantName: String

    var saveCheckboxChecked: Bool = false {
        didSet {
            if saveCheckboxChecked != oldValue {
                notifyUpdate()
            }
        }
    }

    var emailAddress: String? {
        didSet {
            if emailAddress != oldValue {
                onEmailUpdate()
            }
        }
    }

    var phoneNumber: PhoneNumber? {
        didSet {
            if phoneNumber != oldValue {
                notifyUpdate()
            }
        }
    }

    private var linkAccount: PaymentSheetLinkAccount? {
        didSet {
            if linkAccount !== oldValue {
                notifyUpdate()
            }
        }
    }

    private(set) var isLookingUpLinkAccount: Bool = false {
        didSet {
            if isLookingUpLinkAccount != oldValue {
                notifyUpdate()
            }
        }
    }

    var shouldShowEmailField: Bool {
        return saveCheckboxChecked
    }

    var shouldShowPhoneField: Bool {
        guard saveCheckboxChecked,
              let linkAccount = linkAccount
        else {
            return false
        }

        return !linkAccount.isRegistered
    }

    var signupDetails: (PaymentSheetLinkAccount, PhoneNumber)? {
        guard let linkAccount = linkAccount else {
            return nil
        }

        switch linkAccount.sessionState {
        case .requiresSignUp:
            guard let phoneNumber = phoneNumber,
                  phoneNumber.isComplete else {
                return nil
            }
            
            return (linkAccount, phoneNumber)

        default:
            return nil
        }
    }

    init(merchantName: String, accountService: LinkAccountServiceProtocol) {
        self.merchantName = merchantName
        self.accountService = accountService
    }

}

private extension LinkSignupViewModel {

    func notifyUpdate() {
        delegate?.signupViewModelDidUpdate(self)
    }

    func onEmailUpdate() {
        linkAccount = nil

        guard let emailAddress = emailAddress else {
            return
        }

        accountLookupDebouncer.enqueue { [weak self] in
            self?.isLookingUpLinkAccount = true

            self?.accountService.lookupAccount(withEmail: emailAddress) { result in
                self?.isLookingUpLinkAccount = false

                switch result {
                case .success(let account):
                    // Check the received email address against the current one. Handle
                    // email address changes while a lookup is in-flight.
                    if account?.email == self?.emailAddress {
                        self?.linkAccount = account
                    } else {
                        self?.linkAccount = nil
                    }
                case .failure(_):
                    // TODO(ramont): Error handling
                    break
                }
            }
        }
    }

}
