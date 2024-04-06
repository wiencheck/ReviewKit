//
//  AppRatingManager.swift
//  Plum
//
//  Created by Adam Wienconek on 11.08.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import StoreKit
import BoldButton
import AppConfiguration
import SwiftPropertyWrappers

public struct AppReviewManager {
    
    /**
     iTunes identifier pointing to the application.
     
     Needs to be in format like this: `id1441625664`
     */
    public static var applicationiTunesIdentifier: String?
    
    /**
     Set of rules used to determine whether prompt should be presented to the user.
     */
    public static var rules = Rules()
    
    static var isPresenting = false
    
    @available(*, unavailable)
    init() {}
    
    /**
     Evaluates if the prompt should be presented to the user.
     
     - Returns: Boolean indicating whether prompt will be presented to the user.
     */
    @discardableResult
    public static func attemptPresentingAlert() -> Bool {
        if lastAskingDate == nil {
            lastAskingDate = .init()
        }
        if lastAskingVersion == nil {
            lastAskingVersion = .current
        }
        guard !isPresenting, checkIfShouldDisplayPrompt() else {
            return false
        }
        lastAskingDate = Date()
        lastAskingVersion = .current
        presentAlert()
        
        return true
    }
    
    /**
     Displays custom or system feedback prompt to the user.
     
     - Parameters:
     - overrideAskingStatus: If set to `true`, custom prompt will be displayed at all times. Otherwise system prompt will be displayed if current `FeedbackStatus` is negative.
     */
    public static func presentAlert(overrideAskingStatus: Bool = false) {
        Task {
            if overrideAskingStatus || askingStatus == .notDetermined {
                await presentCustomPrompt()
            }
            else if askingStatus != .negative {
                await presentSystemPrompt()
            }
        }
    }
    
    public static func resetValues() {
        lastAskingDate = nil
        lastAskingVersion = nil
        askingStatus = .notDetermined
    }
    
}

public extension AppReviewManager {
    
    @UserDefaultsStorage("appreview_last_date")
    internal(set) static var lastAskingDate: Date!
    
    @UserDefaultsStorage("appreview_last_version")
    internal(set) static var lastAskingVersion: AppVersion!
    
    @UserDefaultsStorage(
        "appreview_feedback_status",
        defaultValue: .notDetermined
    )
    internal(set) static var askingStatus: FeedbackStatus
    
    @UserDefaultsStorage(
        "appreview_did_open_appstore_review",
        defaultValue: false
    )
    internal(set) static var userDidOpenAppStoreReviewPage: Bool
    
}

// MARK: Private stuff
private extension AppReviewManager {
    
    static func checkIfShouldDisplayPrompt() -> Bool {
        if askingStatus == .negative {
            return false
        }
        if !rules.appConfigurations.contains(.current) {
            return false
        }
        if Date().daysBetween(end: lastAskingDate) < rules.numberOfDaysBetweenAskingAttempts {
            return false
        }
        if lastAskingVersion == .current && !rules.shouldAskForTheSameVersionMoreThanOnce {
            return false
        }
        
        return true
    }
    
    @MainActor
    static func presentSystemPrompt() {
        guard let focused = UIWindowScene.focused else {
            assertionFailure("*** Couldn't obtain window scene")
            return
        }
        SKStoreReviewController.requestReview(in: focused)
    }
    
    @MainActor
    static func presentCustomPrompt() {
        let vc = AppFeedbackViewController()
        vc.modalPresentationStyle = .formSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.preferredCornerRadius = 12
        }
        vc.isModalInPresentation = true
        vc.show(animated: true)
    }
    
}
