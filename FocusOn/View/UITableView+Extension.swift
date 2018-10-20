//
//  UITableView+Extension.swift
//  FocusOn
//
//  Created by Spencer Forrest on 20/10/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

extension UITableView {
  /// Request tableView to update its UI
  ///
  /// - Parameter bool: Default value is false
  func updateUI(withAnimation bool: Bool = false) {
    // Request tableView to update its UI
    UIView.setAnimationsEnabled(bool)
    self.beginUpdates()
    self.endUpdates()
    UIView.setAnimationsEnabled(true)
  }
}
