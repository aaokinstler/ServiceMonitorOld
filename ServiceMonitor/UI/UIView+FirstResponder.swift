//
//  UIView+FirstResponder.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 26.09.2021.
//

import UIKit

extension UIView {
    func currentFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }
        
        for view in self.subviews {
            if let responder = view.currentFirstResponder() {
                return responder
            }
        }
        
        return nil
     }
}
