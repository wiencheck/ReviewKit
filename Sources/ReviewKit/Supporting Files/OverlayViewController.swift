//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/05/2021.
//

import UIKit

class OverlayViewController: UIViewController {
    private lazy var overlayView: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = .black
        v.alpha = 0
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setOverlay(hidden: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.overlayView.alpha = hidden ? 0 : 0.3
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let style: UIStatusBarStyle?
        if #available(iOS 13.0, *) {
            style = UIWindowScene.focused?.statusBarManager?.statusBarStyle
        } else {
            style = UIApplication.shared.keyWindow?.rootViewController?.preferredStatusBarStyle
        }
        return style ?? .default
    }

    override var prefersStatusBarHidden: Bool {
        let isHidden: Bool?
        if #available(iOS 13.0, *) {
            isHidden = UIWindowScene.focused?.statusBarManager?.isStatusBarHidden
        } else {
            isHidden = UIApplication.shared.keyWindow?.rootViewController?.prefersStatusBarHidden
        }
        return isHidden ?? false
    }
}
