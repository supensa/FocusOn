//
//  FocusOnTests.swift
//  FocusOnTests
//
//  Created by Spencer Forrest on 23/10/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import XCTest
import CoreData
@testable import FocusOn

class FocusOnTests: XCTestCase {
  
  var dataController: DataController!
  
  var todayViewController: TodayViewController!
  var focus: Focus!
  var focuses = [Focus]()
  
  override func setUp() {
    super.setUp()
    let bundle = Bundle(for: DataController.self)
    let managedObjectModel = NSManagedObjectModel.mergedModel(from: [bundle])!
    let persistentStoreDescription = NSPersistentStoreDescription()
    persistentStoreDescription.type = NSInMemoryStoreType
    dataController = DataController(xcdatamodeldName: Constant.datamodelName,
                                        managedObjectModel: managedObjectModel,
                                        persistentStoreDescription: persistentStoreDescription)
    dataController.load()
  }
  
  override func tearDown() {
    emptyAll()
    dataController = nil
  }
  
  func testGivenCreatingNeWFocus_WhenSavingContext_ThenNoError() {
    _ = createFocus()
  }
  
  func testGivenUpdatingFocus_WhenSavingContext_ThenNoError() {
    let focus = createFocus()
    focus.title = "Updating Focus"
    do {
      try dataController.saveContext()
    } catch {
      XCTFail()
    }
  }
  
  func testGivenDeletingFocus_WhenSavingContext_ThenNoError() {
    let focus = createFocus()
    dataController.context.delete(focus)
    do {
      try dataController.saveContext()
    } catch {
      XCTFail()
    }
  }
  
  func testGivenProgressViewDidLoad_WhenFetchingLastUncompletedFocus_ThenLastUncompletedFocusFetched() {
    let date = "2018-12-17 00:00:00"
    _ = self.createFocus(date: date, type: .goal, isCompleted: false)
    let todayDataManager = TodayDataManager(self.dataController)
    let focus = todayDataManager.requestLastUncompletedGoal { XCTFail() }
    if let focus = focus {
      let resultDate = getString(from: focus.date ?? Date())
      let isCompleted = focus.isCompleted
      let isGoal = focus.type == Type.goal.rawValue
      XCTAssertEqual(resultDate, date)
      XCTAssertTrue(isGoal)
      XCTAssertFalse(isCompleted)
    } else {
      XCTFail()
    }
  }
  
  func testGivenProgressViewDidLoad_WhenFetchingTodayFocus_ThenTodayFocusFetched() {
    let focus = self.createFocus()
    let todayDataManager = TodayDataManager(self.dataController)
    let results = todayDataManager.fetchResultsController(date: Date(), errorHandler: { XCTFail() })
    if let result = results.fetchedObjects?.first {
      XCTAssertEqual(focus.date, result.date)
    } else {
      XCTFail()
    }
  }
  
  func testGivenProgressViewDidLoad_WhenFetchingMonthlyCompletedFocuses_ThenMonthlyCompletedFocusesFetched() {
    createDummyDates()
    let goals = createDummyGoals()
    let tasks = createDummyTasks(goals: goals)
    let progressDataManager = ProgressDataManager.init(dataController)
    let results = progressDataManager.monthlyCompletedFocuses()
    var percentages = percentage(data: goals)
    var month = [percentages[0]]
    var currentMonth = [percentages[1]]
    percentages = percentage(data: tasks)
    month.append(percentages[0])
    currentMonth.append(percentages[1])
    let monthSymbol = Calendar.current.shortMonthSymbols[self.month-1]
    let index = Calendar.current.component(.month, from: date)
    let currentMonthSymbol = Calendar.current.shortMonthSymbols[index-1]
    XCTAssertNotNil(results[currentMonthSymbol])
    XCTAssertNotNil(results[monthSymbol])
    XCTAssertEqual(results[currentMonthSymbol]![0], currentMonth[0])
    XCTAssertEqual(results[currentMonthSymbol]![1], currentMonth[1])
    XCTAssertEqual(results[monthSymbol]![0], month[0])
    XCTAssertEqual(results[monthSymbol]![1], month[1])
  }
  
  func testGivenProgressViewDidLoad_WhenFetchingWeeklyCompletedFocuses_ThenWeeklyCompletedFocusesFetched() {
    createDummyDates()
    let goals = createDummyGoals()
    let tasks = createDummyTasks(goals: goals)
    let progressDataManager = ProgressDataManager.init(dataController)
    let results = progressDataManager.weeklyCompletedFocuses()
    var percentages = percentage(data: goals)
    var weeks = [percentages[1]]
    percentages = percentage(data: tasks)
    weeks.append(percentages[1])
    XCTAssertNotNil(results[week])
    XCTAssertEqual(results[week]![0], weeks[0])
    XCTAssertEqual(results[week]![1], weeks[1])
  }
  
  func testGivenHistoryViewDidLoad_WhenFetchingAllFocus_ThenAllFocusFetched() {
    createDummyDates()
    let goals: [Focus] = createDummyGoals().reversed()
    let tasks: [Focus] = createDummyTasks(goals: goals)
    let historyDataManager = HistoryDataManager.init(dataController)
    let fetchedResults = historyDataManager.historyFetchResultsController()
    let gs = fetchedResults.fetchedObjects?.filter({ $0.type == Type.goal.rawValue })
    let ts = fetchedResults.fetchedObjects?.filter({ $0.type == Type.task.rawValue })
    XCTAssertEqual(gs?.count, goals.count)
    XCTAssertEqual(ts?.count, tasks.count)
    if gs?.count == goals.count && ts?.count == tasks.count {
      for index in 0...dates.count - 1 {
        XCTAssertEqual(ts?[index].objectID, tasks[index].objectID)
        XCTAssertEqual(gs?[index].objectID, goals[index].objectID)
      }
    }
  }
  
  private func percentage(data: [Focus]) -> [Double] {
    var count = 0
    for index in 0...2 {
      let focus = data[index]
      if focus.isCompleted {
        count += 1
      }
    }
    var percentages: [Double] = [Double(count * 100) / 3.0]
    count = 0
    for index in 3...5 {
      let focus = data[index]
      if focus.isCompleted {
        count += 1
      }
    }
    percentages.append(Double(count * 100) / 3.0)
    return percentages
  }
  
  var dates = [String]()
  var datesShort = [String]()
  let week = "Week 2"
  let month = 1
  let date = Date()
  
  private func createDummyDates() {
    dates = [String]()
    let calendar = Calendar.current
    let currentMonth = calendar.component(.month, from: date)
    let year = calendar.component(.year, from: date)
    dates.append("\(year)-\(month)-02 00:00:00")
    dates.append("\(year)-\(month)-03 00:00:00")
    dates.append("\(year)-\(month)-04 00:00:00")
    dates.append("\(year)-\(currentMonth)-10 00:00:00")
    dates.append("\(year)-\(currentMonth)-11 00:00:00")
    dates.append("\(year)-\(currentMonth)-12 00:00:00")
    datesShort = [calendar.shortMonthSymbols[month-1], calendar.shortMonthSymbols[currentMonth-1]]
  }
  
  private func createDummyGoals() -> [Focus] {
    var goals = [Focus]()
    for date in dates {
      let isCompleted = Int.random(in: 0...1) == 0
      let goal = createFocus(date: date, isCompleted: isCompleted)
      goals.append(goal)
    }
    return goals
  }
  
  private func createDummyTasks(goals: [Focus]) -> [Focus] {
    var tasks = [Focus]()
    for goal in goals {
      guard let date = goal.date else {
        XCTFail()
        return [Focus]()
      }
      let isCompleted = goal.isCompleted ? true : Int.random(in: 0...1) == 1
      let task = createFocus(date: date, type: .task, isCompleted: isCompleted)
      tasks.append(task)
    }
    return tasks
  }
  
  private func getString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = Constant.defaultDateFormat
    
    return formatter.string(from: date)
  }
  
  private func emptyAll() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    for focus in focuses {
      dataController.context.delete(focus)
    }
    do {
      try dataController.saveContext()
    } catch {
      fatalError("\(error.localizedDescription)")
    }
    self.focuses = [Focus]()
  }
  
  private func createFocus(date: Date = Date(),
                           title: String = "TEST",
                           type: Type = .goal,
                           isCompleted: Bool = false,
                           order: Int16 = -1) -> Focus {
    let focus = Focus(context: dataController.context)
    focus.date = date
    focus.title = title
    focus.isCompleted = isCompleted
    focus.order = order
    focus.type = type.rawValue
    focuses.append(focus)
    do {
      try dataController.saveContext()
    } catch {
      XCTFail()
    }
    return focus
  }
  
  private func createFocus(date: String,
                           title: String = "TEST",
                           type: Type = .goal,
                           isCompleted: Bool = false,
                           order: Int16 = -1) -> Focus {
    var focus = Focus(context: dataController.context)
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = Constant.defaultDateFormat
    if let date = formatter.date(from: date) {
     focus = self.createFocus(date: date, title: title, type: type, isCompleted: isCompleted, order: order)
    } else {
     XCTFail()
    }
    return focus
  }
}
