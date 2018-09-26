//
//  GoalTableViewCell.swift
//  FocusOn
//
//  Created by Spencer Forrest on 24/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

protocol GoalTableViewCellDelegate {
  func processGoalInput(formerText: String?, text: String?, type: Type) -> Void
}

class GoalTableViewCell: UITableViewCell {
  
  @IBOutlet weak var textField: UITextField!
  
  var delegate: TableViewCellDelegate?
  var formerText: String?
  
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
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    formerText = textField.text
    textField.text = ""
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    guard formerText != textField.text else { return }
    self.delegate?.processInput(formerText: formerText, text: textField.text, typeCell: .goal)
  }
}
