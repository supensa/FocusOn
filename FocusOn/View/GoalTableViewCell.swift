//
//  GoalTableViewCell.swift
//  FocusOn
//
//  Created by Spencer Forrest on 24/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

class GoalTableViewCell: TableViewCell {
  
  @IBOutlet weak var title: UITextView!
  @IBOutlet weak var checkmarkLabel: UILabel!
  
  
  override func awakeFromNib() {
    self.textView = title
    self.label = checkmarkLabel
    super.awakeFromNib()
    placeHolderText = Constant.goalPlaceHolder
  }
}
