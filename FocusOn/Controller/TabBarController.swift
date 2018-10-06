//
//  TabBarController.swift
//  FocusOn
//
//  Created by Spencer Forrest on 23/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    // Load second tab bar item
    self.selectedIndex = 0
  }
}
