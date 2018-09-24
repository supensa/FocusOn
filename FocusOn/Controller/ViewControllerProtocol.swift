//
//  ViewControllerProtocol.swift
//  FocusOn
//
//  Created by Spencer Forrest on 23/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

protocol ViewControllerProtocol where Self: UIViewController {
  var dataController: DataController! {get set}
}
