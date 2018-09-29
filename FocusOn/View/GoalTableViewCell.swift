//
//  GoalTableViewCell.swift
//  FocusOn
//
//  Created by Spencer Forrest on 24/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

class GoalTableViewCell: UITableViewCell {
  
  @IBOutlet weak var textView: UITextView!
  
  var delegate: TableViewCellDelegate?
  var formerText: String?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    textView.delegate = self
    textView.isScrollEnabled = false
  }
}

// -------------------------------------------------------------------------
// MARK: - Text field delegate
extension GoalTableViewCell: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    formerText = textView.text
    delegate?.resize(cell: self)
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    textView.text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    guard formerText != textView.text else { return }
    self.delegate?.textFieldDidFinishEditing(text: textView.text, typeCell: .goal, tag: nil)
  }
  
  func textViewDidChange(_ textView: UITextView) {
    delegate?.resize(cell: self)
  }
}
