//
//  TableViewCell.swift
//  FocusOn
//
//  Created by Spencer Forrest on 30/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

  weak var textView: UITextView!
  
  var delegate: TableViewCellDelegate?
  var formerText: String?
    
  override func awakeFromNib() {
    super.awakeFromNib()
    textFieldDelegation()
    setupTextViewBorder()
  }
  
  func setupTextViewBorder() {
    self.textView.layer.borderWidth = 1.0;
    self.textView.layer.borderColor = UIColor.lightGray.cgColor
    self.textView.layer.cornerRadius = 8;
    self.textView.clipsToBounds = true
  }
  
  private func textFieldDelegation() {
    textView.delegate = self
    textView.isScrollEnabled = false
  }
}

// -------------------------------------------------------------------------
// MARK: - Text view delegate
extension TableViewCell: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    formerText = textView.text
    delegate?.resize(cell: self)
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    textView.text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    clearCheckMarkIfNeeded()
    delegate?.textViewDidFinishEditing(cell: self, tag: self.tag)
  }
  
  func textViewDidChange(_ textView: UITextView) {
    clearCheckMarkIfNeeded()
    delegate?.resize(cell: self)
  }
  
  private func clearCheckMarkIfNeeded() {
    if textView.text == "" {
      self.accessoryType = .none
      self.isSelected = false
    }
  }
}
