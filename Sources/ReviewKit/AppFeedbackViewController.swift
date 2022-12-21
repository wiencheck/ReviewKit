//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/05/2021.
//

import UIKit
import StoreKit
import BoldButton
import OverlayPresentable

public class AppFeedbackViewController: UIViewController, OverlayPresentable {
    
    public static var configuration = AppFeedbackViewControllerConfiguration()
    
    public weak var window: UIWindow?
    
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
    
    private lazy var feedbackGenerator = UIImpactFeedbackGenerator()
        
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
        AppReviewManager.isPresenting = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        feedbackGenerator.prepare()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AppReviewManager.isPresenting = false
        cleanupAfterPresentation()
    }
    
}

private extension AppFeedbackViewController {
    
    func handleOptionSelected(_ sender: UIControl) {
        switch sender {
        case primaryButton:
            AppReviewManager.askingStatus = .posititve
            primaryButton.pressHandler = { [weak self] _ in
                self?.dismiss(animated: true, completion: {
                    Self.configuration.primaryButtonActionHandler?(true)
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
            if AppReviewManager.askingStatus == .negative {
                AppReviewManager.askingStatus = .notDetermined
            }
            dismiss(animated: true)
            return
        }
        
        updateContents(basedOnStatus: AppReviewManager.askingStatus, animated: true)
    }
    
    func updateContents(basedOnStatus feedbackStatus: FeedbackStatus, animated: Bool) {
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
    
    func setupView() {
        let spacing: CGFloat = 14
        
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(container)
        
        let stack = UIStackView(arrangedSubviews: [mainLabel, secondaryLabel, primaryButton, secondaryButton, tertiaryButton])
        stack.axis = .vertical
        stack.spacing = spacing
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            
            container.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            container.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            container.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            container.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            container.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            stack.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.8),
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
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
