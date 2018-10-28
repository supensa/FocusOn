//
//  Constant.swift
//  FocusOn
//
//  Created by Spencer Forrest on 23/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit

struct Constant {
  static let datamodelName = "Datamodel"
  static let persistentStorePath = "Application Support/Persistent Store"
  
  static let contextSavingErrorMessage = "There was a problem saving your data but it is not your fault."
    + "If you restart the app, you can try again."
    + "Please contact support to notify us of this issue:\n"
  static let contextSavingErrorTitle = "Could Not Save Data"
  
  static let goalCellId = "GoalCellId"
  static let taskCellId = "TaskCellId"
  
  static let taskCompletion = "Great job on making progress!"
  static let taskAttempt = "ah, no biggie, you’ll get it next time!"
  
  static let checkmark = "\u{2714}"
  
  static let taskPlaceHolder = "Define task"
  static let goalPlaceHolder = "Set your goal..."
  static let focusPlaceHolder = "Write text here"
  static let placeHolderColor = UIColor(r: 200, g: 200, b: 200, alpha: 1)
  
  static let goalCompleted = "Congratulation !"
  static let goalUncompleted = "Goal for the day to focus on:"
  static let taskCompleted = "All tasks completed !"
  static let taskUncompleted = " more to achieve your goal"
  
  static let selectionBackgroundColor = UIColor(r: 239, g: 239, b: 244, alpha: 1)
  
  static let today = "Today"
  static let sectionDateFormat = "MMMM dd, yyyy"
  static let titleDateFormat = "MMMM yyyy"
  static let defaultDateFormat = "yyyy-MM-dd HH:mm:ss"
  static let yearDateFormat = "yyyy"
  static let monthShortDateFormat = "MMM"
  static let monthDateFormat = "MMM"
  
  static let monthlySegmentIndex = 0
  static let weeklySegmentIndex = 1
  
  static func monthlyDateFormat(year: Int) -> String {
    return "\(year)-01-01 00:00:00"
  }
  
  static func weeklyDateFormat(year: Int, month: Int) -> String {
    return "\(year)-\(month)-01 00:00:00"
  }
}
