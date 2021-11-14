//
//  NavigationControllerVC.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 06.11.2021.
//

import Foundation
import UIKit

class NavigationControllerVC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .didReceiveError, object: nil)
    }
    
    @objc func handleNotification(_ notification: Notification) {
        // handle errors of background context
        if let message = notification.userInfo?["error"] as? String {
            let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertVC, animated: true, completion: nil)
         }
    }
}
