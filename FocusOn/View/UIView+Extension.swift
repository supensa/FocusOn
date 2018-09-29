//
//  UIView+Extension.swift
//  FocusOn
//
//  Created by Spencer Forrest on 29/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

extension UIView {
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
