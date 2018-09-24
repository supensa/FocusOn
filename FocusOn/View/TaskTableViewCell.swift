//
//  TaskTableViewCell.swift
//  FocusOn
//
//  Created by Spencer Forrest on 24/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
  
  
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var numberLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    numberLabel.layer.cornerRadius = numberLabel.frame.width * 0.35
    numberLabel.clipsToBounds = true
    textField.delegate = self
  }
}

// -------------------------------------------------------------------------
// MARK: - Text field delegate
extension TaskTableViewCell: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.endEditing(true)
    return true
  }
}
