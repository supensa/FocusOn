//
//  TaskTableViewCell.swift
//  FocusOn
//
//  Created by Spencer Forrest on 24/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

protocol TaskTableViewCellDelegate {
  func saveTask(text: String?, type: Type, tag index: Int) -> Void
}

class TaskTableViewCell: UITableViewCell {
  
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var numberLabel: UILabel!
  
  var delegate: TaskTableViewCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    numberLabel.layer.cornerRadius = numberLabel.bounds.height * 0.35
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
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    delegate?.saveTask(text: textField.text, type: Type.task, tag: self.tag)
  }
}
