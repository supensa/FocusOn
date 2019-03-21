//
//  Progress.swift
//  FocusOn
//
//  Created by Spencer Forrest on 16/10/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import Foundation
import CoreData

class Progress {
  var labels: [String] {
    return _labels
  }
  private var _labels = [String]()
  private let dataController: DataController!
  
  init(_ dataController: DataController) {
    self.dataController = dataController
  }
  
  /**
   Return percentages of completed Focuses sorted by time in ascending order.
   
   - Parameter isWeekly: Weekly or monthly report
   - Returns: A tuple of arrays
      - First: Goals
      - Last: Tasks
   */
  func completedFocuses(isWeekly: Bool) -> ([Double],[Double]) {
    let results = isWeekly ? weeklyCompletedFocuses() : monthlyCompletedFocuses()
    var completedTasks = [Double]()
    var completedGoals = [Double]()
    for label in _labels {
      if let goalResult = results[label]?.first {
        completedGoals.append(goalResult)
      }
      if let taskResult = results[label]?.last {
        completedTasks.append(taskResult)
      }
    }
    return (completedGoals, completedTasks)
  }
  
  /**
   Data concerning the percentages of completed focuses (goals and tasks) for each month.
   
   The data are stored in a dictionary:
   * Key: Reprensation of the month (short month symbols)
   * Value: Array of focuses
      * First: Percentage of completed Goals
      * Last: Percentage of completed Tasks
   - Returns: dictionary
   */
  private func monthlyCompletedFocuses() -> [String:[Double]] {
    var dataStructure = [String:[Double]]()
    var data = [Focus]()
    if let results = self.progressFetchResultsController(isMonthly: true).fetchedObjects {
      data = results
    }
    self._labels = [String]()
    let goals = self.percentageOfMonthlyCompletedFocuses(data: data, type: Type.goal.rawValue)
    let tasks = self.percentageOfMonthlyCompletedFocuses(data: data, type: Type.task.rawValue)
    let months = self.months(data)
    if !goals.isEmpty || !tasks.isEmpty {
      dataStructure = self.dataStructureForMonthlyCompletedFocuses(months: months, goals: goals, tasks: tasks)
    }
    return dataStructure
  }
  
  /**
   Data concerning the percentages of completed focuses (goals and tasks) for each week.
   
   The data are stored in a dictionary:
   * Key: Reprensation of the week
   * Value: Array of focuses
      * First: Percentage of completed Goals
      * Last: Percentage of completed Tasks
   - Returns: dictionary
   */
  private func weeklyCompletedFocuses() -> [String:[Double]] {
    var dataStructure = [String:[Double]]()
    var data = [Focus]()
    if let results = self.progressFetchResultsController(isMonthly: false).fetchedObjects {
      data = results
    }
    self._labels = [String]()
    let goals = self.percentageOfWeeklyCompletedFocuses(data: data, type: Type.goal.rawValue)
    let tasks = self.percentageOfWeeklyCompletedFocuses(data: data, type: Type.task.rawValue)
    if !goals.isEmpty || !tasks.isEmpty {
      dataStructure = self.dataStructureForWeeklyCompletedFocuses(goals: goals, tasks: tasks)
    }
    return dataStructure
  }
  
  private func progressFetchResultsController(isMonthly: Bool) -> NSFetchedResultsController<Focus> {
    let fetchRequest: NSFetchRequest<Focus> = Focus.fetchRequest()
    let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    fetchRequest.sortDescriptors = [dateSortDescriptor]
    let dates = self.period(isMonthly: isMonthly)
    let predicate = dataController.datePredicate(from: dates.0, to: dates.1)
    fetchRequest.predicate = predicate
    let fetchedResultsController =
      NSFetchedResultsController(fetchRequest: fetchRequest,
                                 managedObjectContext: dataController.context,
                                 sectionNameKeyPath: "date",
                                 cacheName: nil)
    try? fetchedResultsController.performFetch()
    return fetchedResultsController
  }
  
  /// Return percentage of completed Focuses (Goal or Task) per month
  /// - Parameters:
  ///   - data: Array of all Focuses
  ///   - type: Type of Focus (goal or task) to analyze
  /// - Returns: Percentage of completed Focuses(Goal or Task) per month
  private func percentageOfMonthlyCompletedFocuses(data: [Focus], type: String) -> [Double] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = Constant.monthShortDateFormat
    var lastMonth = ""
    if let data = data.first { lastMonth = dateFormatter.string(from: (data.date)!) }
    var total = 0
    var count = 0
    
    var focuses = [Double]()
    for index in 0..<data.count {
      let focus = data[index]
      let month = dateFormatter.string(from: focus.date!)
      
      if month != lastMonth {
        focuses.append(self.percentage(count: count, total: total))
        lastMonth = month
        count = 0
        total = 0
      }
      
      if focus.type == type {
        total += 1
        if focus.isCompleted { count += 1 }
      }
      
      if month == lastMonth && index + 1 == data.count {
        focuses.append(self.percentage(count: count, total: total))
      }
    }
    return focuses
  }
  
  /** Create a dictionary of data.
  - Parameters:
    - months: Array of labels (short month symbols)
    - goals: Array containing percentage of completed goals
    - tasks: Array containing percentage of completed tasks
  - Returns: Dictionary of percentages of completed Goals and Tasks per Week
    - Key: Label representing the month (e.g "Jan")
    - Value: Array containing percentage of completed focuses:
      - First: Goal
      - Last: Task
  */
  private func dataStructureForMonthlyCompletedFocuses(months: [String], goals: [Double], tasks: [Double]) -> [String:[Double]] {
    var results = [String:[Double]]()
    _labels = Calendar.current.shortMonthSymbols.reversed()
    for labels in _labels {
      results[labels] = [0,0]
    }
    for index in 0..<months.count {
      let month = months[index]
      let goal = goals[index]
      let task = tasks[index]
      results[month] = [goal, task]
    }
    return results
  }
  
  private func months(_ focuses: [Focus]?) -> [String] {
    var months = [String]()
    var lastMonth = ""
    var data = [Focus]()
    if let focuses = focuses {
      data = focuses
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = Constant.monthShortDateFormat
    
    for focus in data {
      let month = dateFormatter.string(from: focus.date!)
      if month != lastMonth {
        months.append(month)
        lastMonth = month
      }
    }
    return months
  }
  
  private func period(isMonthly: Bool) -> (Date, Date) {
    // Get today's Year and Month
    let today = Date()
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    let month = calendar.component(.month, from: today)
    let year = calendar.component(.year, from: today)
    // Begining and End date represented as string
    let startTime = isMonthly ? Constant.monthlyDateFormat(year: year) : Constant.weeklyDateFormat(year: year, month: month)
    var endTime = ""
    if isMonthly {
      endTime = Constant.monthlyDateFormat(year: year + 1)
    } else {
      if month < 12 {
        endTime = Constant.weeklyDateFormat(year: year , month: month + 1)
      } else {
        endTime = Constant.weeklyDateFormat(year: year + 1, month: 1)
      }
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = Constant.defaultDateFormat
    dateFormatter.timeZone = TimeZone.current
    // Get 2 Dates from strings
    var start = Date()
    var end = Date()
    if let date = dateFormatter.date(from: startTime) {
      start = date
    }
    if let date = dateFormatter.date(from: endTime) {
      end = date
    }
    // return 2 Dates as tuples
    return (start, end)
  }
  
  /** Return percentage of completed Focuses (Goal or Task) per week
  - Parameters:
    - data: Array of all Focuses
    - type: Type of Focus (goal or task) to analyze
  - Returns: percentage of completed Focuses(Goal or Task) per week:
    - Key: Numerical representation of week
    - Value: Percentage
  */
  private func percentageOfWeeklyCompletedFocuses(data: [Focus], type: String) -> [Int:Double] {
    var focuses: [Int:Double] = [:]
    var lastWeek = 0
    if !data.isEmpty {
      lastWeek = weekComponent(date: (data.first?.date)!)
    }
    var count = 0
    var total = 0
    for index in 0..<data.count {
      let focus = data[index]
      let week = weekComponent(date: focus.date!)
      
      if week != lastWeek {
        focuses[lastWeek] = self.percentage(count: count, total: total)
        lastWeek = week
        count = 0
        total = 0
      }
      
      if focus.type == type {
        total += 1
        if focus.isCompleted { count += 1 }
      }
      
      if week == lastWeek && index + 1 == data.count {
        focuses[lastWeek] = self.percentage(count: count, total: total)
      }
    }
    return focuses
  }
  
  private func percentage(count: Int, total: Int) -> Double {
    var result = 0.0
    if total != 0 { result = Double(count) * 100 / Double(total) }
    return result
  }
  
  private func weekComponent(date: Date) -> Int {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current
    let day = Double(calendar.component(.day, from: date))
    return Int(ceil(day/7.0))
  }
  
  /** Create a dictionary of data.
  - Parameters:
    - goals: Percentages of completed goals per Week
    - tasks: Percentages of completed tasks per Month
  - Returns: Dictionary of percentages of completed Goals and Tasks per Week
    - Key: Label representing the week (e.g "Week 0")
    - Value: Array containing percentage of completed focuses:
      - First: Goal
      - Last: Task
  */
  private func dataStructureForWeeklyCompletedFocuses(goals: [Int:Double], tasks: [Int:Double]) -> [String:[Double]] {
    var results = self.initResultsAndUpdateLabels()
    // Update with the data from Goals and Tasks
    for (key,value) in goals {
      let label = "Week \(key)"
      var task = 0.0
      if let result = tasks[key] { task = result }
      results[label] = [value, task]
    }
    for (key,value) in tasks {
      let label = "Week \(key)"
      var goal = 0.0
      if let result = goals[key] { goal = result }
      results[label] = [goal, value]
    }
    return results
  }
  
  private func initResultsAndUpdateLabels() -> [String:[Double]] {
    self._labels = [String]()
    // Get number of days this month
    let numberDays = Double(numberOfDaysIn(date: Date()))
    let numberWeeks = Int(ceil(numberDays/7.0))
    // Initializes all the days to [0.0]
    var results = [String:[Double]]()
    for index in 1...numberWeeks {
      let label = "Week \(index)"
      results["\(label)"] = [0,0]
      self._labels.append(label)
    }
    self._labels.reverse()
    return results
  }
  
  private func numberOfDaysIn(date: Date) -> Int {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current
    let range = calendar.range(of: .day, in: .month, for: date)!
    let numDays = range.count
    return numDays
  }
}
