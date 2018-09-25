//
//  GoalTableViewCell.swift
//  FocusOn
//
//  Created by Spencer Forrest on 24/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

protocol GoalTableViewCellDelegate {
  func saveGoal(text: String?) -> Void
}

class GoalTableViewCell: UITableViewCell {
  
  @IBOutlet weak var textField: UITextField!
  
  var delegate: GoalTableViewCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    textField.delegate = self
  }
}

// -------------------------------------------------------------------------
// MARK: - Text field delegate
extension GoalTableViewCell: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.endEditing(true)
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    self.delegate?.saveGoal(text: textField.text)
  }
}
