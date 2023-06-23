//
//  PhoneOtpViewController.swift
//  StripeIdentity
//
//  Created by Chen Cen on 6/14/23.
//

@_spi(STP) import StripeUICore
import UIKit

class PhoneOtpViewController: IdentityFlowViewController {
    private let phoneOtpContent: StripeAPI.VerificationPageStaticContentPhoneOtpPage

    let phoneOtpView: PhoneOtpView

    var flowViewModel: IdentityFlowView.ViewModel {
        return .init(
            headerViewModel: .init(
                backgroundColor: .systemBackground,
                headerType: .plain,
                titleText: phoneOtpContent.title
            ),
            contentView: phoneOtpView,
            buttons: [
                .init(
                    text: phoneOtpContent.resendButtonText,
                    state: {
                        switch phoneOtpView.viewModel {
                        case .InputtingOTP:
                            return .enabled
                        case .SubmittingOTP:
                            return .disabled
                        case .ErrorOTP:
                            return .enabled
                        case .RequestingOTP:
                            return .loading
                        case .RequestingCannotVerify:
                            return .disabled
                        }
                    }(),
                    isPrimary: false,
                    didTap: {
                        self.generateOtp()
                    }
                ),
                .init(
                    text: phoneOtpContent.cannotVerifyButtonText,
                    state: {
                        switch phoneOtpView.viewModel {
                        case .InputtingOTP:
                            return .enabled
                        case .SubmittingOTP:
                            return .disabled
                        case .ErrorOTP:
                            return .enabled
                        case .RequestingOTP:
                            return .disabled
                        case .RequestingCannotVerify:
                            return .loading
                        }
                    }(),
                    isPrimary: false,
                    didTap: {
                        self.phoneOtpView.configure(with: .RequestingCannotVerify)
                        self.sheetController?.sendCannotVerifyPhoneOtpAndTransition { [weak self] in
                            self?.phoneOtpView.reset()
                        }
                    }
                ),
            ]
        )
    }

    init(
        phoneOtpContent: StripeAPI.VerificationPageStaticContentPhoneOtpPage,
        sheetController: VerificationSheetControllerProtocol
    ) {
        self.phoneOtpContent = phoneOtpContent

        let bodyText = {
            if let localPhoneNumber = sheetController.collectedData.phone {
                return phoneOtpContent.body.replacingOccurrences(of: "&phone_number&", with: "(***)*****\(localPhoneNumber.number!.suffix(2))")
            } else {
                return phoneOtpContent.body.replacingOccurrences(of: "&phone_number&", with: phoneOtpContent.redactedPhoneNumber!)
            }
        }()

        phoneOtpView = PhoneOtpView(otpLength: phoneOtpContent.otpLength,
                                    body: bodyText, errorString: phoneOtpContent.errorOtpMessage)

        super.init(sheetController: sheetController, analyticsScreenName: .phoneOtp)

        phoneOtpView.delegate = self

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        generateOtp()
    }

    func updateUI() {
        configure(
            backButtonTitle: STPLocalizedString(
                "Phone Verification",
                "Back button title for returning to the phone verification page"
            ),
            viewModel: flowViewModel
        )
    }
}

extension PhoneOtpViewController: PhoneOtpViewDelegate {
    ///
    func didInputFullOtp(newOtp: String) {
        phoneOtpView.configure(with: .SubmittingOTP(newOtp))

        sheetController?.saveOtpAndMaybeTransition(from: .phoneOtp, otp: newOtp, completion: { [weak self] in
            self?.phoneOtpView.reset()
        }) { [weak self] in
            self?.phoneOtpView.configure(with: .ErrorOTP)
        }
    }

    func viewStateDidUpdate() {
        updateUI()
    }
}

extension PhoneOtpViewController {
    /// Generate OTP, when sucess, trnasition to InputtingOTP
    func generateOtp() {
        phoneOtpView.configure(with: .RequestingOTP)
        sheetController?.generatePhoneOtp { [weak self] _ in
            self?.phoneOtpView.configure(with: .InputtingOTP)
        }
    }
}
