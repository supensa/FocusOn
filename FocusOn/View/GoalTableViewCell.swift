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
  
  override func awakeFromNib() {
    self.textView = title
    super.awakeFromNib()
  }
}
