//
//  TaskTableViewCell.swift
//  FocusOn
//
//  Created by Spencer Forrest on 24/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

protocol TaskTableViewCellDelegate {
  func processTaskInput(formerText: String?, text: String?, type: Type, tag index: Int) -> Void
}

class TaskTableViewCell: UITableViewCell {
  
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var numberLabel: UILabel!
  
  var delegate: TableViewCellDelegate?
  private var formerText: String?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    setupRoundLabel()
    textFieldDelegation()
  }
  
  private func setupRoundLabel() {
    numberLabel.layer.cornerRadius = numberLabel.bounds.height * 0.35
    numberLabel.clipsToBounds = true
  }
  
  private func textFieldDelegation() {
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
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    formerText = textField.text
    textField.text = ""
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    guard formerText != textField.text else { return }
    delegate?.processInput(formerText: formerText, text: textField.text, typeCell: .task, tag: self.tag)
  }
}
