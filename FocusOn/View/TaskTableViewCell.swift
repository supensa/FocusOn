//
//  TaskTableViewCell.swift
//  FocusOn
//
//  Created by Spencer Forrest on 24/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
  
  @IBOutlet weak var textView: UITextView!
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
    numberLabel.layer.cornerRadius = numberLabel.bounds.height * 0.5
    numberLabel.clipsToBounds = true
  }
  
  private func textFieldDelegation() {
    textView.delegate = self
    textView.isScrollEnabled = false
  }
}

// -------------------------------------------------------------------------
// MARK: - Text view delegate
extension TaskTableViewCell: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    formerText = textView.text
    delegate?.resize(cell: self)
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    textView.text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    guard formerText != textView.text else { return }
    delegate?.textFieldDidFinishEditing(text: textView.text, typeCell: .task, tag: self.tag)
  }
  
  func textViewDidChange(_ textView: UITextView) {
    delegate?.resize(cell: self)
  }
}
