//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/05/2021.
//

import UIKit

public struct AppFeedbackViewControllerConfiguration {
    /**
     Tint color applied to the view controller. Default value is nil
     */
    public var tintColor: UIColor?
    
    /**
     Closure used for configuring title text of the prompt based on current `FeedbackStatus` value.
     */
    public var titleText: ((FeedbackStatus) -> String)
    
    /**
     Closure used for configuring message text of the prompt based on current `FeedbackStatus` value.
     */
    public var messageText: ((FeedbackStatus) -> String)
    
    /**
     Closure used for configuring primary button text of the prompt based on current `FeedbackStatus` value.
     */
    public var primaryButtonTitle: ((FeedbackStatus) -> String?)
    
    /**
     Closure used for configuring secondary button text of the prompt based on current `FeedbackStatus` value.
     */
    public var secondaryButtonTitle: ((FeedbackStatus) -> String?)
    
    /**
     Text of the last button in the prompt that performs a dismissal action.
     */
    public var dismissButtonTitle: String?
    
    /**
     Action performed after selecting primary button.
     
     Use the `FeedbackStatus` value to choose appriopriate action.
     */
    public var primaryButtonActionHandler: ((Bool) -> Void)?
    
    /**
     Action performed after selecting secondary button.
     
     Use the `FeedbackStatus` value to choose appriopriate action.
     */
    public var secondaryButtonActionHandler: ((Bool) -> Void)?
    
    init() {
        titleText = { status in
            switch status {
            case .posititve:
                return DefaultMessages.titlePositive
            case .negative:
                return DefaultMessages.titleNegative
            case .notDetermined:
                return DefaultMessages.titleNotDetermined
            }
        }
        messageText = { status in
            switch status {
            case .posititve:
                return DefaultMessages.messagePositive
            case .negative:
                return DefaultMessages.messageNegative
            case .notDetermined:
                return DefaultMessages.messageNotDetermined
            }
        }
        primaryButtonTitle = { status in
            switch status {
            case .posititve:
                return DefaultMessages.primaryButtonPositive
            case .notDetermined:
                return DefaultMessages.primaryButtonNotDetermined
            default:
                return nil
            }
        }
        secondaryButtonTitle = { status in
            switch status {
            case .notDetermined:
                return DefaultMessages.secondaryButtonNotDetermined
            case .negative:
                return DefaultMessages.secondaryButtonNegative
            default:
                return nil
            }
        }
        dismissButtonTitle = DefaultMessages.tertiaryButton
    }
}
