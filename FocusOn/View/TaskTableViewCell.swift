//
//  TaskTableViewCell.swift
//  FocusOn
//
//  Created by Spencer Forrest on 24/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

class TaskTableViewCell: TableViewCell {
  
  @IBOutlet weak var title: UITextView!
  @IBOutlet weak var numberLabel: UILabel!
  @IBOutlet weak var checkmarkLabel: UILabel!
  
  override func awakeFromNib() {
    self.textView = title
    self.label = checkmarkLabel
    super.awakeFromNib()
    setupRoundLabel()
    placeHolderText = Constant.taskPlaceHolder
  }
  
  private func setupRoundLabel() {
    numberLabel.layer.cornerRadius = numberLabel.bounds.height * 0.5
    numberLabel.clipsToBounds = true
  }
}
