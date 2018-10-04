//
//  UIColor+Extension.swift
//  FocusOn
//
//  Created by Spencer Forrest on 02/10/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

extension UIColor {
  convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) {
    self.init(red: r/255, green: g/255, blue: b/255, alpha: alpha)
  }
  
  static let darkGreen = UIColor(r: 0, g: 100, b: 0, alpha: 1)
}
