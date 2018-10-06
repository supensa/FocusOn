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
  static let managedObjectModelDocument = "momd"
  static let persistentStorePath = "Application Support/Persistent Store"
  
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
  static let sectionDateFormat = "MMMM dd, YYYY"
  static let titleDateFormat = "MMMM YYYY"
  
  static let testDateFormat = "YYYY-MM-dd"
}
