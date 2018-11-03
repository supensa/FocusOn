//
//  TableViewCellTests.swift
//  FocusOnTests
//
//  Created by Spencer Forrest on 03/11/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import XCTest
@testable import FocusOn

class TableViewCellTests: XCTestCase {
  
  func testGivenHistoryTableViewCellDidLoad_WhenLoading_ThenLoaded() {  
    let cell = HistoryTableViewCell()
    let textView = UITextView()
    cell.textView = textView
    cell.awakeFromNib()
    XCTAssertEqual(cell.textView.isUserInteractionEnabled, false)
    XCTAssertEqual(cell.textView.isScrollEnabled, false)
  }
  
  func testGivenTableViewCellDidLoad_WhentextViewDidChange_ThenTextNil() {
    let cell = TableViewCell(frame: .zero)
    let textView = UITextView(frame: .zero)
    let label = UILabel(frame: .zero)
    cell.textView = textView
    cell.label = label
    cell.awakeFromNib()
    cell.setCheckmark(true)
    cell.textView.text = ""
    // Checkmark is added
    XCTAssertEqual(cell.label.text, Constant.checkmark)
    cell.textViewDidChange(cell.textView)
    // Checkmark is removed
    XCTAssertEqual(cell.label.text, "")
  }
  
  func testGivenTableViewCellDidLoad_WhenTextViewDidEndEditing_ThenTextNil() {
    let cell = TableViewCell(frame: .zero)
    let textView = UITextView(frame: .zero)
    let label = UILabel(frame: .zero)
    cell.textView = textView
    cell.label = label
    cell.awakeFromNib()
    cell.textView.text = ""
    cell.textViewDidEndEditing(cell.textView)
    // Checkmark is removed
    XCTAssertEqual(cell.label.text, "")
    // Check placeholder is added
    XCTAssertEqual(cell.textView.text, Constant.focusPlaceHolder)
  }
  
  func testGivenTableViewCellDidLoad_WhenTextViewDidBeginEditing_ThenTextNil() {
    let cell = TableViewCell(frame: .zero)
    let textView = UITextView(frame: .zero)
    let label = UILabel(frame: .zero)
    cell.textView = textView
    cell.label = label
    cell.awakeFromNib()
    cell.textViewDidBeginEditing(cell.textView)
    XCTAssertEqual(cell.textView.text, "")
    XCTAssertEqual(cell.formerText, "")
  }
  
  func testGivenTableViewCellDidLoad_WhenSetCheckMark_ThenTextLabelUpdates() {
    let cell = TableViewCell(frame: .zero)
    let textView = UITextView(frame: .zero)
    let label = UILabel(frame: .zero)
    cell.textView = textView
    cell.label = label
    cell.awakeFromNib()
    cell.setCheckmark(false)
    XCTAssertEqual(cell.label.text, "")
    cell.setCheckmark(true)
    XCTAssertEqual(cell.label.text, Constant.checkmark)
  }
  
  func testGivenTableViewCellDidLoad_WhenCheckPlaceHolder_ThenPlaceHolderChecked() {
    let cell = TableViewCell(frame: .zero)
    let textView = UITextView(frame: .zero)
    let label = UILabel(frame: .zero)
    cell.textView = textView
    cell.label = label
    cell.awakeFromNib()
    let boolean = cell.isPlaceHolderSet()
    XCTAssertEqual(boolean, true)
  }
}
