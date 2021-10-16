//
//  AppRatingManager.swift
//  Plum
//
//  Created by Adam Wienconek on 11.08.2019.
//  Copyright © 2019 adam.wienconek. All rights reserved.
//

import StoreKit
import BoldButton

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
    
    public static var isLoggingEnabled = true
    
    public static var shouldDisplayOutsideAppStore = false
        
    private static var presentingTask: DispatchWorkItem?
    private init() {}
    
    /**
     Evaluates if the prompt should be presented to the user and increases the number of actions by default.
     
     - Parameters:
        - increaseActionsCount:
     
     - Returns: Boolean indicating whether prompt will be presented to the user.
     */
    @discardableResult
    public static func attemptPresentingAlert(increaseActionsCount: Bool = true) -> Bool {
        if increaseActionsCount {
            actionsCounter += 1
        }
        guard shouldDisplayMessage else {
            return false
        }
        presentingTask?.cancel()
        presentingTask = DispatchWorkItem {
            actionsCounter = 0
            lastAskingDate = Date()
            lastAskingVersion = UIApplication.shared.appVersion
            presentAlert()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: presentingTask!)
        return true
    }
    
    /**
     Displays custom or system feedback prompt to the user.
     
     - Parameters:
        - overrideAskingStatus: If set to `true`, custom prompt will be displayed at all times. Otherwise system prompt will be displayed if current `FeedbackStatus` is negative.
     */
    public static func presentAlert(overrideAskingStatus: Bool = false) {
        // If false, user pressed negative feedback option.
        if askingStatus == .negative && !overrideAskingStatus {
            presentSystemPrompt()
        } else {
            presentCustomPrompt()
        }
    }
    
    public static func openAppStoreReviewForm() {
        guard let identifier = AppReviewManager.applicationiTunesIdentifier,
              let url = URL(string: "itms-apps://apple.com/app/\(identifier)?action=write-review"),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    public static func resetValues() {
        actionsCounter = 0
        lastAskingDate = nil
        lastAskingVersion = nil
        askingStatus = .notDetermined
    }
}

// - MARK: Private stuff
extension AppReviewManager {
    private static var shouldDisplayMessage: Bool {
        if rules.isDebugging {
            return true
        }
        if UIApplication.shared.configuration != .release,
           !shouldDisplayOutsideAppStore {
            log("Feedback prompt will not be presented because app is not in release configuration.")
            return false
        }
        if askingStatus == .posititve {
            log("Feedback prompt will not be presented because askingStatus is already positive.")
            // User selected positive option and hopefully already rated in the app store.
            return false
        }
        
        var checks = [Bool]()
        if let date = lastAskingDate {
            // Set to true if X days have passed since last asking date.
            checks.append(abs(Date().daysBetween(end: date)) > rules.numberOfDaysBetweenAskingAttempts)
        }
        if let version = lastAskingVersion {
            if version == UIApplication.shared.appVersion {
                // Set to true if version is the same and rules state that it should ask
                checks.append(rules.shouldAskForTheSameVersionMoreThanOnce)
            } else {
                // Set to true if versions differ
                checks.append(true)
            }
        }
        // Set to true if more actions have been performed
        checks.append(actionsCounter > rules.numberOfActionsPerformed)
        
        let willPresent = checks.allSatisfy({ $0 })
        if willPresent {
            log("Feedback prompt will be presented")
        } else {
            var message = """
                Feedback prompt will not be presented.
                Current status: \(askingStatus)
                \(actionsCounter) actions, rules: \(rules.numberOfActionsPerformed)
                """
            if let date = lastAskingDate {
                message += "\nLast display date: \(date), asks every \(rules.numberOfDaysBetweenAskingAttempts) days"
            }
            if let version = lastAskingVersion {
                message += ",\nLast display version: \(version), current version: \(UIApplication.shared.appVersion), should ask more than once: \(rules.shouldAskForTheSameVersionMoreThanOnce)"
            }
            log(message)
        }
        return willPresent
    }
    
    private static func presentSystemPrompt() {
        if #available(iOS 14.0, *), let focused = UIWindowScene.focused {
            SKStoreReviewController.requestReview(in: focused)
        } else {
            SKStoreReviewController.requestReview()
        }
    }
    
    private static func presentCustomPrompt() {
        AppFeedbackViewController().show(animated: true)
    }
    private static func log(_ message: String) {
        guard isLoggingEnabled else { return }
        print("ReviewKit: ", message)
    }
}

extension AppReviewManager {
    private static var userDefaultsLastDateKey: String {
        return "AppReviewManagerLastAskingDate"
    }
    
    private static var userDefaultsLastVersionKey: String {
        return "AppReviewManagerLastAskingVersion"
    }
    
    private static var userDefaultsStatusKey: String {
        return "AppReviewManagerStatusKey"
    }
    
    private static var userDefaultsActionsCounterKey: String {
        return "AppReviewManagerActionsCounterKey"
    }
    
    private static var userDefaultsUserDidOpenAppStoreKey: String {
        return "AppReviewManagerUserDidOpenAppStoreKey"
    }
}

extension AppReviewManager {
    private static var lastAskingDate: Date? {
        get {
            guard let interval = UserDefaults.standard.value(forKey: Self.userDefaultsLastDateKey) as? Double else {
                return nil
            }
            return Date(timeIntervalSince1970: interval)
        } set {
            UserDefaults.standard.set(newValue?.timeIntervalSince1970, forKey: Self.userDefaultsLastDateKey)
        }
    }
    
    private static var lastAskingVersion: String? {
        get {
            return UserDefaults.standard.string(forKey: Self.userDefaultsLastVersionKey)
        } set {
            UserDefaults.standard.set(newValue, forKey: Self.userDefaultsLastVersionKey)
        }
    }
    
    private static var actionsCounter: Int {
        get {
            return UserDefaults.standard.integer(forKey: Self.userDefaultsActionsCounterKey)
        } set {
            UserDefaults.standard.set(newValue, forKey: Self.userDefaultsActionsCounterKey)
        }
    }
    
    static var askingStatus: FeedbackStatus {
        get {
            let rawValue = UserDefaults.standard.integer(forKey: Self.userDefaultsStatusKey)
            return FeedbackStatus(rawValue: rawValue) ?? .notDetermined
        } set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Self.userDefaultsStatusKey)
        }
    }
    
    public static var userDidOpenAppStoreReviewPage: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Self.userDefaultsUserDidOpenAppStoreKey)
        } set {
            UserDefaults.standard.set(newValue, forKey: Self.userDefaultsUserDidOpenAppStoreKey)
        }
    }
}
