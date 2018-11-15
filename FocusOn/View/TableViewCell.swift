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
  weak var label: UILabel!
  
  var delegate: TableViewCellDelegate?
  var formerText: String?
  var placeHolderText = Constant.focusPlaceHolder
    
  override func awakeFromNib() {
    super.awakeFromNib()
    textFieldDelegation()
    setupTextViewBorder()
    setCheckmark(false)
    setPlaceHolder()
  }
  
  /// Put a place holder into the cell's textView
  func setPlaceHolder() {
    textView.textColor = Constant.placeHolderColor
    textView.text = placeHolderText
  }
  
  /// Check if place holder is set into the cell's textView
  ///
  /// - Returns: True if the placeholder is set
  func isPlaceHolderSet() -> Bool {
    return textView.text == placeHolderText
  }
  
  /// Add or remove checkmark in the cell
  ///
  /// - Parameter bool: True to set the checkmark
  func setCheckmark(_ bool: Bool) {
    label.text = bool ? Constant.checkmark : ""
  }
  
  private func setupTextViewBorder() {
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
  // Remove placeholder when textView starts to be edited
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == placeHolderText {
      textView.text = ""
    }
    textView.textColor = UIColor.black
    formerText = textView.text
    delegate?.dynamicSize(cell: self)
  }
  
  // Set placeHolder when textView is empty
  // Call delegation method to notify that the textView did finish editing
  func textViewDidEndEditing(_ textView: UITextView) {
    textView.text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    clearCheckMarkIfNeeded()
    delegate?.textViewDidFinishEditing(cell: self, tag: self.tag)
    // Place holder last so not saved in persistent store
    if textView.text == "" {
      setPlaceHolder()
    }
  }
  
  // Dynamically change the size of the textView
  // when text changes.
  func textViewDidChange(_ textView: UITextView) {
    clearCheckMarkIfNeeded()
    delegate?.dynamicSize(cell: self)
  }
  
  private func clearCheckMarkIfNeeded() {
    let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    if text == "" {
      self.setCheckmark(false)
      self.isSelected = false
    }
  }
}
