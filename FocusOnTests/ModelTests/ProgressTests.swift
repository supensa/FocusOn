//
//  ProgressTests.swift
//  FocusOnTests
//
//  Created by Spencer Forrest on 03/11/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import XCTest
import CoreData
@testable import FocusOn

class ProgressTests: XCTestCase {

  var focus: Focus!
  var focuses = [Focus]()
  
  lazy var dataController: DataController = {
    let managedObjectModel = DataController.model
    let persistentStoreDescription = NSPersistentStoreDescription()
    persistentStoreDescription.type = NSInMemoryStoreType
    let dataController = DataController(xcdatamodeldName: Constant.datamodelName,
                                        managedObjectModel: managedObjectModel,
                                        persistentStoreDescription: persistentStoreDescription)
    dataController.load()
    return dataController
  }()
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    for focus in focuses {
      dataController.context.delete(focus)
    }
    try? dataController.saveContext()
    self.focuses = [Focus]()
  }
  
  func testGivenProgress_WhenFetchingMonthlyCompletedFocusesPercentage_ThenMonthlyCompletedFocusesPercentageFetched() {
    dataForCurrentYear()
    let progress = Progress.init(dataController)
    let results = progress.completedFocuses(isWeekly: false)
    let goalResults: [Double] = results.0.reversed()
    let taskResults: [Double] = results.1.reversed()
    
    XCTAssertEqual(goalResults[0], 3.0 * 100.0 / 3.0)
    XCTAssertEqual(goalResults[1], 1.0 * 100.0 / 3.0)
    XCTAssertEqual(goalResults[2], 0.0 * 100.0 / 3.0)
    XCTAssertEqual(goalResults[3], 2.0 * 100.0 / 3.0)
    XCTAssertEqual(goalResults[4], 3.0 * 100.0 / 3.0)
    XCTAssertEqual(goalResults[5], 1.0 * 100.0 / 3.0)
    XCTAssertEqual(goalResults[6], 0.0 * 100.0 / 3.0)
    XCTAssertEqual(goalResults[7], 2.0 * 100.0 / 3.0)
    XCTAssertEqual(goalResults[8], 3.0 * 100.0 / 3.0)
    XCTAssertEqual(goalResults[9], 1.0 * 100.0 / 3.0)
    XCTAssertEqual(goalResults[10], 0.0 * 100.0 / 3.0)
    XCTAssertEqual(goalResults[11], 2.0 * 100.0 / 3.0)
    
    XCTAssertEqual(taskResults[0], 0.0 * 100.0 / 3.0)
    XCTAssertEqual(taskResults[1], 1.0 * 100.0 / 3.0)
    XCTAssertEqual(taskResults[2], 2.0 * 100.0 / 3.0)
    XCTAssertEqual(taskResults[3], 3.0 * 100.0 / 3.0)
    XCTAssertEqual(taskResults[4], 3.0 * 100.0 / 3.0)
    XCTAssertEqual(taskResults[5], 2.0 * 100.0 / 3.0)
    XCTAssertEqual(taskResults[6], 1.0 * 100.0 / 3.0)
    XCTAssertEqual(taskResults[7], 0.0 * 100.0 / 3.0)
    XCTAssertEqual(taskResults[8], 1.0 * 100.0 / 3.0)
    XCTAssertEqual(taskResults[9], 3.0 * 100.0 / 3.0)
    XCTAssertEqual(taskResults[10], 0.0 * 100.0 / 3.0)
    XCTAssertEqual(taskResults[11], 2.0 * 100.0 / 3.0)
    
    let labels: [String] = progress.labels.reversed()
    XCTAssertEqual(labels[0], "Jan")
    XCTAssertEqual(labels[1], "Feb")
    XCTAssertEqual(labels[2], "Mar")
    XCTAssertEqual(labels[3], "Apr")
    XCTAssertEqual(labels[4], "May")
    XCTAssertEqual(labels[5], "Jun")
    XCTAssertEqual(labels[6], "Jul")
    XCTAssertEqual(labels[7], "Aug")
    XCTAssertEqual(labels[8], "Sep")
    XCTAssertEqual(labels[9], "Oct")
    XCTAssertEqual(labels[10], "Nov")
    XCTAssertEqual(labels[11], "Dec")
  }
  
  func testGivenProgress_WhenFetchingWeeklyCompletedFocusesPercentage_ThenWeeklyCompletedFocusesPercentageFetched() {
    dataForCurrentMonth()
    let progress = Progress.init(dataController)
    let results = progress.completedFocuses(isWeekly: true)
    let goalResults: [Double] = results.0.reversed()
    let taskResults: [Double] = results.1.reversed()
    XCTAssertEqual(goalResults[0], 3.0 * 100.0 / 3.0)
    XCTAssertEqual(goalResults[1], 1.0 * 100.0 / 3.0)
    XCTAssertEqual(goalResults[2], 0.0 * 100.0 / 3.0)
    XCTAssertEqual(goalResults[3], 2.0 * 100.0 / 3.0)
    
    XCTAssertEqual(taskResults[0], 8.0 * 100.0 / 9.0)
    XCTAssertEqual(taskResults[1], 5.0 * 100.0 / 9.0)
    XCTAssertEqual(taskResults[2], 2.0 * 100.0 / 9.0)
    XCTAssertEqual(taskResults[3], 7.0 * 100.0 / 9.0)
    
    let labels: [String] = progress.labels.reversed()
    XCTAssertEqual(labels[0], "Week 1")
    XCTAssertEqual(labels[1], "Week 2")
    XCTAssertEqual(labels[2], "Week 3")
    XCTAssertEqual(labels[3], "Week 4")
    XCTAssertEqual(labels[4], "Week 5")
  }
  
  private func dataForCurrentYear() {
    // 3 days for each week (no day for 5th week)
    let dates = currentYearDates()
    let tuple = instantiateFocusesForCurrentYear(dates: dates)
    let goals = tuple.0
    let tasks = tuple.1
    setupGoalsForCurrentYear(goals)
    setupTasksForCurrentYear(tasks)
    // 36 goals and 36 Tasks
    XCTAssertEqual(goals.count, dates.count)
    XCTAssertEqual(tasks.count, dates.count)
    saveContext()
  }
  
  private func currentYearDates() -> [String] {
    let today = Date()
    let calender = Calendar.current
    let year = calender.component(.year, from: today)
    var dates = [String]()
    for month in 1...12 {
      for day in 3...5 {
        let date = "\(year)-\(month)-\(day) 00:00:00"
        dates.append(date)
      }
    }
    return dates
  }
  
  private func dataForCurrentMonth() {
    let today = Date()
    let calender = Calendar.current
    let year = calender.component(.year, from: today)
    let month = calender.component(.month, from: today)
    // 3 days for each week (no day for 5th week)
    let dates = [
      "\(year)-\(month)-03 00:00:00",
      "\(year)-\(month)-04 00:00:00",
      "\(year)-\(month)-05 00:00:00",
      
      "\(year)-\(month)-10 00:00:00",
      "\(year)-\(month)-11 00:00:00",
      "\(year)-\(month)-12 00:00:00",
      
      "\(year)-\(month)-16 00:00:00",
      "\(year)-\(month)-17 00:00:00",
      "\(year)-\(month)-18 00:00:00",
      
      "\(year)-\(month)-23 00:00:00",
      "\(year)-\(month)-24 00:00:00",
      "\(year)-\(month)-25 00:00:00",
    ]
    let tuple = instantiateFocusesForCurrentMonth(dates: dates)
    let goals = tuple.0
    let tasks = tuple.1
    setupGoalsForCurrentMonth(goals)
    setupTasksForCurrentMonth(tasks)
    // 12 goals and 36 Tasks
    XCTAssertEqual(goals.count, dates.count)
    XCTAssertEqual(tasks.count, dates.count * 3)
    saveContext()
  }
  
  /**
   Completed Goals per Month
   
   * Month 1: 3/3
   * Month 2: 1/3
   * Month 3: 0/3
   * Month 4: 2/3
   * Month 5: 3/3
   * Month 6: 1/3
   * Month 7: 0/3
   * Month 8: 2/3
   * Month 9: 3/3
   * Month 10: 1/3
   * Month 11: 0/3
   * Month 12: 2/3
   
   - Parameter goals: goals to setup
   */
  private func setupGoalsForCurrentYear(_ goals: [Focus]) {
    // 100% | 3
    goals[0].isCompleted = true
    goals[1].isCompleted = true
    goals[2].isCompleted = true
    // 33.33% | 1
    goals[3].isCompleted = false
    goals[4].isCompleted = false
    goals[5].isCompleted = true
    // 0% | 0
    goals[6].isCompleted = false
    goals[7].isCompleted = false
    goals[8].isCompleted = false
    // 66.66% | 2
    goals[9].isCompleted = true
    goals[10].isCompleted = false
    goals[11].isCompleted = true
    // 100% | 3
    goals[12].isCompleted = true
    goals[13].isCompleted = true
    goals[14].isCompleted = true
    // 33.33% | 1
    goals[15].isCompleted = false
    goals[16].isCompleted = false
    goals[17].isCompleted = true
    // 0% | 0
    goals[18].isCompleted = false
    goals[19].isCompleted = false
    goals[20].isCompleted = false
    // 66.66% | 2
    goals[21].isCompleted = true
    goals[22].isCompleted = false
    goals[23].isCompleted = true
    // 100% | 3
    goals[24].isCompleted = true
    goals[25].isCompleted = true
    goals[26].isCompleted = true
    // 33.33% | 1
    goals[27].isCompleted = false
    goals[28].isCompleted = false
    goals[29].isCompleted = true
    // 0% | 0
    goals[30].isCompleted = false
    goals[31].isCompleted = false
    goals[32].isCompleted = false
    // 66.66% | 2
    goals[33].isCompleted = true
    goals[34].isCompleted = false
    goals[35].isCompleted = true
  }
  
  /**
   Completed Tasks per Month
   
   * Month 1: 0/3
   * Month 2: 1/3
   * Month 3: 2/3
   * Month 4: 3/3
   * Month 5: 3/3
   * Month 6: 2/3
   * Month 7: 1/3
   * Month 8: 0/3
   * Month 9: 1/3
   * Month 10: 3/3
   * Month 11: 0/3
   * Month 12: 2/3
   
   - Parameter tasks: tasks to setup
   */
  private func setupTasksForCurrentYear(_ tasks:[Focus]) {
    // 0% | 0
    tasks[0].isCompleted = false
    tasks[1].isCompleted = false
    tasks[2].isCompleted = false
    // 33.33% | 1
    tasks[3].isCompleted = false
    tasks[4].isCompleted = false
    tasks[5].isCompleted = true
    // 66.66% | 2
    tasks[6].isCompleted = false
    tasks[7].isCompleted = true
    tasks[8].isCompleted = true
    // 100% | 3
    tasks[9].isCompleted = true
    tasks[10].isCompleted = true
    tasks[11].isCompleted = true
    // 100% | 3
    tasks[12].isCompleted = true
    tasks[13].isCompleted = true
    tasks[14].isCompleted = true
    // 66.66% | 2
    tasks[15].isCompleted = false
    tasks[16].isCompleted = true
    tasks[17].isCompleted = true
    // 33.33% | 1
    tasks[18].isCompleted = false
    tasks[19].isCompleted = false
    tasks[20].isCompleted = true
    // 0% | 0
    tasks[21].isCompleted = false
    tasks[22].isCompleted = false
    tasks[23].isCompleted = false
    // 33.33% | 1
    tasks[24].isCompleted = false
    tasks[25].isCompleted = false
    tasks[26].isCompleted = true
    // 100% | 3
    tasks[27].isCompleted = true
    tasks[28].isCompleted = true
    tasks[29].isCompleted = true
    // 0% | 0
    tasks[30].isCompleted = false
    tasks[31].isCompleted = false
    tasks[32].isCompleted = false
    // 66.66% | 2
    tasks[33].isCompleted = false
    tasks[34].isCompleted = true
    tasks[35].isCompleted = true
  }
  
  /**
   Completed Goals per Week in Current Month
   
   * Week 1: 3/3
   * Week 2: 1/3
   * Week 3: 0/3
   * Week 4: 2/3
   
   - Parameter tasks: goals to setup
   */
  private func setupGoalsForCurrentMonth(_ goals: [Focus]) {
    // 100% | 3
    goals[0].isCompleted = true
    goals[1].isCompleted = true
    goals[2].isCompleted = true
    // 33.33% | 1
    goals[3].isCompleted = false
    goals[4].isCompleted = false
    goals[5].isCompleted = true
    // 0% | 0
    goals[6].isCompleted = false
    goals[7].isCompleted = false
    goals[8].isCompleted = false
    // 66.66% | 2
    goals[9].isCompleted = true
    goals[10].isCompleted = false
    goals[11].isCompleted = true
  }
  
  /**
   Completed Tasks per Week in Current Month
   
   * Week 1: 8/9
   * Week 2: 5/9
   * Week 3: 2/9
   * Week 4: 7/9
   
   - Parameter tasks: tasks to setup
   */
  private func setupTasksForCurrentMonth(_ tasks:[Focus]) {
    // 88.88% | 8/9
    tasks[0].isCompleted = true
    tasks[1].isCompleted = true
    tasks[2].isCompleted = true
    tasks[3].isCompleted = true
    tasks[4].isCompleted = true
    tasks[5].isCompleted = true
    tasks[6].isCompleted = true
    tasks[7].isCompleted = true
    tasks[8].isCompleted = false
    // 55.55% | 5/9
    tasks[9].isCompleted = true
    tasks[10].isCompleted = true
    tasks[11].isCompleted = true
    tasks[12].isCompleted = true
    tasks[13].isCompleted = true
    tasks[14].isCompleted = false
    tasks[15].isCompleted = false
    tasks[16].isCompleted = false
    tasks[17].isCompleted = false
    // 22.22% | 2/9
    tasks[18].isCompleted = true
    tasks[19].isCompleted = true
    tasks[20].isCompleted = false
    tasks[21].isCompleted = false
    tasks[22].isCompleted = false
    tasks[23].isCompleted = false
    tasks[24].isCompleted = false
    tasks[25].isCompleted = false
    tasks[26].isCompleted = false
    // 77.77% | 7/9
    tasks[27].isCompleted = true
    tasks[28].isCompleted = true
    tasks[29].isCompleted = true
    tasks[30].isCompleted = true
    tasks[31].isCompleted = true
    tasks[32].isCompleted = true
    tasks[33].isCompleted = true
    tasks[34].isCompleted = false
    tasks[35].isCompleted = false
  }
  
  private func instantiateFocusesForCurrentYear(dates: [String]) -> ([Focus],[Focus]) {
    // create goals and tasks
    var goals = [Focus]()
    var tasks = [Focus]()
    for string in dates {
      if let date = dateFromString(string) {
        let goal = Focus(context: dataController.context)
        goal.type = Type.goal.rawValue
        goal.date = date
        goal.title = ""
        goal.order = -1
        goals.append(goal)
        self.focuses.append(goal)
        
        let task = Focus(context: dataController.context)
        task.type = Type.task.rawValue
        task.date = date
        task.title = ""
        task.order = 0
        tasks.append(task)
        self.focuses.append(task)
      }
    }
    setupGoalsForCurrentYear(goals)
    setupTasksForCurrentYear(tasks)
    return (goals, tasks)
  }
  
  private func instantiateFocusesForCurrentMonth(dates: [String]) -> ([Focus],[Focus]) {
    // create goals and tasks
    var goals = [Focus]()
    var tasks = [Focus]()
    for string in dates {
      if let date = dateFromString(string) {
        let goal = Focus(context: dataController.context)
        goal.type = Type.goal.rawValue
        goal.date = date
        goal.title = ""
        goal.order = -1
        goals.append(goal)
        self.focuses.append(goal)
        
        var task = Focus(context: dataController.context)
        task.type = Type.task.rawValue
        task.date = date
        task.title = ""
        task.order = 0
        tasks.append(task)
        self.focuses.append(task)
        
        task = Focus(context: dataController.context)
        task.type = Type.task.rawValue
        task.date = date
        task.title = ""
        task.order = 1
        tasks.append(task)
        self.focuses.append(task)
        
        task = Focus(context: dataController.context)
        task.type = Type.task.rawValue
        task.date = date
        task.title = ""
        task.order = 2
        tasks.append(task)
        self.focuses.append(task)
      }
    }
    return (goals, tasks)
  }
  
  private func dateFromString(_ string: String) -> Date? {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = Constant.defaultDateFormat
    return formatter.date(from: string)
  }
  
  private func saveContext() {
    do {
      try dataController.saveContext()
    } catch {
      let error = error as NSError
      XCTFail(error.debugDescription)
    }
  }
}
