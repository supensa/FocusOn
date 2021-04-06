//
//  ViewController.swift
//  FocusOn
//
//  Created by Spencer Forrest on 23/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  /// Manage the core data stack
  var dataController: DataController {
    return _dataController
  }
  
  private var _dataController: DataController!
  /// Has to be called in AppDelegate to Inject "DataController" Dependency
  ///
  /// - Parameter dataController: dataController in charge of persistant container
  func setupDataController(_ dataController: DataController) {
    _dataController = dataController
  }
}
