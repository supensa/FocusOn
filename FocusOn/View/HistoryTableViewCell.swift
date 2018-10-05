//
//  HistoryTableViewCell.swift
//  FocusOn
//
//  Created by Spencer Forrest on 05/10/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
  
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var label: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    textView.isScrollEnabled = false
    textView.isUserInteractionEnabled = false
  }
}
