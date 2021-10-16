//
//  ViewController.swift
//  ReviewKitExample
//
//  Created by Adam Wienconek on 11/05/2021.
//

import UIKit
import ReviewKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func handleButtonTapped(_ sender: UIButton) {
        if AppReviewManager.attemptPresentingAlert() {
            return
        }
        AppReviewManager.presentAlert(overrideAskingStatus: true)
    }
}

