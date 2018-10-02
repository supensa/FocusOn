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
  var placeHolderText = "Insert Text here..."
    
  override func awakeFromNib() {
    super.awakeFromNib()
    textFieldDelegation()
    setupTextViewBorder()
    setPlaceHolder()
  }
  
  func setPlaceHolder() {
    textView.textColor = UIColor(r: 200, g: 200, b: 200, alpha: 1)
    textView.text = placeHolderText
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
    if textView.text == placeHolderText {
      textView.text = ""
    }
    textView.textColor = UIColor.black
    formerText = textView.text
    delegate?.dynamicSize(cell: self)
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    textView.text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    clearCheckMarkIfNeeded()
    delegate?.textViewDidFinishEditing(cell: self, tag: self.tag)
    // Place holder last so not saved in persistent store
    if textView.text == "" {
      setPlaceHolder()
    }
  }
  
  func textViewDidChange(_ textView: UITextView) {
    clearCheckMarkIfNeeded()
    delegate?.dynamicSize(cell: self)
  }
  
  private func clearCheckMarkIfNeeded() {
    let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    if text == "" {
      self.accessoryType = .none
      self.isSelected = false
    }
  }
}
