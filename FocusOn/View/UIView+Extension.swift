//
//  UIView+Extension.swift
//  FocusOn
//
//  Created by Spencer Forrest on 29/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

extension UIView {
  /// Look into subviews to find the first responder
  var firstResponder: UIView? {
    guard !isFirstResponder else { return self }
    
    for subview in subviews {
      if let firstResponder = subview.firstResponder {
        return firstResponder
      }
    }
    return nil
  }
}
