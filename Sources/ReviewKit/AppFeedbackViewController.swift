//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/05/2021.
//

import UIKit
import StoreKit
import BoldButton

public class AppFeedbackViewController: UIViewController {
    public static var configuration = AppFeedbackViewControllerConfiguration()
    
    private lazy var mainLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .headline)
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()
    
    private lazy var secondaryLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .preferredFont(forTextStyle: .body)
        l.numberOfLines = 0
        return l
    }()
    
    private lazy var primaryButton: BoldButton = {
        let b = BoldButton()
        b.isSelected = true
        b.pressHandler = { [weak self] sender in
            self?.handleOptionSelected(sender)
        }
        return b
    }()
    
    private lazy var secondaryButton: BoldButton = {
        let b = BoldButton()
        b.isSelected = false
        b.pressHandler = { [weak self] sender in
            self?.handleOptionSelected(sender)
        }
        return b
    }()
    
    private lazy var tertiaryButton: UIButton = {
        let b = Button(type: .system)
        b.pressHandler = { [weak self] sender in
            self?.handleOptionSelected(sender)
        }
        b.text = DefaultMessages.tertiaryButton
        return b
    }()
    
    private lazy var alertWindow: UIWindow? = {
        let window: UIWindow
        if #available(iOS 13.0, *),
           let focused = UIWindowScene.focused {
            window = UIWindow(windowScene: focused)
            window.tintColor = focused.windows.first(where: \.isKeyWindow)?.tintColor
        } else {
            window = UIWindow()
            window.tintColor = UIApplication.shared.keyWindow?.tintColor
        }
        window.rootViewController = OverlayViewController()
        window.backgroundColor = .clear
        if let tintColor = Self.configuration.tintColor {
            window.tintColor = tintColor
        }
        window.windowLevel = UIWindow.Level.alert
        return window
    }()
    
    private lazy var feedbackGenerator = UIImpactFeedbackGenerator()
    
    private var overlayVc: OverlayViewController? {
        return presentingViewController as? OverlayViewController
    }
        
    init() {
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupView()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        updateContents(basedOnStatus: AppReviewManager.askingStatus, animated: false)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overlayVc?.setOverlay(hidden: false)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        feedbackGenerator.prepare()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        overlayVc?.setOverlay(hidden: true)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        alertWindow = nil
    }

    func show(animated flag: Bool) {
        guard let alertWindow = alertWindow,
           let rootViewController = alertWindow.rootViewController else {
            return
        }
        alertWindow.makeKeyAndVisible()
        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .overFullScreen
        rootViewController.present(self, animated: flag, completion: nil)
    }
    
    private func handleOptionSelected(_ sender: UIControl) {
        switch sender {
        case primaryButton:
            AppReviewManager.askingStatus = .posititve
            primaryButton.pressHandler = { [weak self] _ in
                self?.dismiss(animated: true, completion: {
                    if let handler = Self.configuration.primaryButtonActionHandler {
                        handler(true)
                    } else {
                        AppReviewManager.openAppStoreReviewForm()
                    }
                })
            }
            secondaryButton.pressHandler = { [weak self] _ in
                self?.dismiss(animated: true, completion: {
                    Self.configuration.secondaryButtonActionHandler?(true)
                })
            }
        case secondaryButton:
            AppReviewManager.askingStatus = .negative
            primaryButton.pressHandler = { [weak self] _ in
                self?.dismiss(animated: true, completion: {
                    Self.configuration.primaryButtonActionHandler?(false)
                })
            }
            secondaryButton.pressHandler = { [weak self] _ in
                self?.dismiss(animated: true, completion: {
                    Self.configuration.secondaryButtonActionHandler?(false)
                })
            }
        default:
            // If user pressed positive review and then "maybe later", we will show him the system dialog in the future.
            if AppReviewManager.askingStatus == .posititve {
                AppReviewManager.askingStatus = .negative
            } else {
                AppReviewManager.askingStatus = .notDetermined
            }
            dismiss(animated: true)
            return
        }
        
        updateContents(basedOnStatus: AppReviewManager.askingStatus, animated: true)
    }
    
    private func updateContents(basedOnStatus feedbackStatus: FeedbackStatus, animated: Bool) {
        func animations() {
            mainLabel.text = Self.configuration.titleText(feedbackStatus)
            mainLabel.isHidden = (mainLabel.text == nil)
            
            secondaryLabel.text = Self.configuration.messageText(feedbackStatus)
            secondaryLabel.isHidden = (secondaryLabel.text == nil)
            
            primaryButton.text = Self.configuration.primaryButtonTitle(feedbackStatus)
            primaryButton.isHidden = (primaryButton.text == nil)
            
            secondaryButton.text = Self.configuration.secondaryButtonTitle(feedbackStatus)
            secondaryButton.isHidden = (secondaryButton.text == nil)
            
            tertiaryButton.setTitle(Self.configuration.dismissButtonTitle, for: .normal)
            tertiaryButton.isHidden = (Self.configuration.dismissButtonTitle == nil)
            
            view.layoutIfNeeded()
        }
        
        guard animated else {
            animations()
            return
        }
        
        UIView.animate(withDuration: 0.34,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.9,
                       options: [.curveLinear, .layoutSubviews],
                       animations: animations,
                       completion: nil)
    }
    
    private func setupView() {
        var constraints = [NSLayoutConstraint]()
        let spacing: CGFloat = 14
        
        let background = UIView(frame: .zero)
        background.backgroundColor = .background
        background.layer.cornerRadius = 18
        background.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner respectively
        
        view.addSubview(background)
        background.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let stack = UIStackView(arrangedSubviews: [mainLabel, secondaryLabel, primaryButton, secondaryButton, tertiaryButton])
        stack.axis = .vertical
        stack.spacing = spacing
        stack.alignment = .fill
        
        background.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            stack.topAnchor.constraint(equalTo: background.safeAreaLayoutGuide.topAnchor, constant: spacing),
            stack.centerXAnchor.constraint(equalTo: background.safeAreaLayoutGuide.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: background.safeAreaLayoutGuide.centerYAnchor),
            stack.widthAnchor.constraint(lessThanOrEqualToConstant: 420),
            stack.widthAnchor.constraint(equalTo: background.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8)
        ])
        constraints.last?.priority = UILayoutPriority(999)
        
        NSLayoutConstraint.activate(constraints)
    }
}

fileprivate class Button: UIButton {
    var pressHandler: ((Button) -> Void)?
    
    var text: String? {
        get {
            return title(for: .normal)
        } set {
            setTitle(newValue, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addTarget(self, action: #selector(handleTouchUpInside), for: .touchUpInside)
    }
    
    @objc private func handleTouchUpInside() {
        pressHandler?(self)
    }
}
