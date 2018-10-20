//
//  Calendar+Ext.swift
//  FocusOn
//
//  Created by Spencer Forrest on 18/10/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import Foundation

extension Calendar {
  /// Returns the value for the week of a date.
  /// A week is a group of 7 days starting by the 1st of the month
  /// e.g. 1-5 for first to fifth week
  ///
  /// - parameter date: The date to use.
  /// - returns: The value for the week.
  public func weekComponent(date: Date) -> Int {
    let day = Double(self.component(.day, from: date))
    let week = Int(ceil(day/7.0))
    return week
  }
}
