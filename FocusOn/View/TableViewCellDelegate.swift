//
//  TableViewCellDelegate.swift
//  FocusOn
//
//  Created by Spencer Forrest on 26/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate {
  /// Called everytime a textField inside the cell finished to be edited
  ///
  /// - Parameters:
  ///   - cell: cell containing the textView
  ///   - index: index used for task cell
  func textViewDidFinishEditing(cell: TableViewCell, tag index: Int)
  /// Resize a cell accordingly to the text inside its textView.
  /// Keep the bottom of the cell visible on the screen
  ///
  /// - Parameter cell: cell to resize if needed
  func dynamicSize(cell: TableViewCell)
}
