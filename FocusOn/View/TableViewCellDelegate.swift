//
//  TableViewCellDelegate.swift
//  FocusOn
//
//  Created by Spencer Forrest on 26/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import Foundation

protocol TableViewCellDelegate {
  func processInput(formerText: String?, text: String?, typeCell: Type, tag index: Int?)
  func processInput(formerText: String?, text: String?, typeCell: Type)
}
