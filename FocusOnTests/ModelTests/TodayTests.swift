//
//  TodayTests.swift
//  FocusOnTests
//
//  Created by Spencer Forrest on 23/10/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import XCTest
import CoreData
@testable import FocusOn

class TodayTests: XCTestCase {
  
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
  
  var focus: Focus!
  var focuses = [Focus]()
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    for focus in focuses {
      dataController.context.delete(focus)
    }
    try? dataController.saveContext()
    self.focuses = [Focus]()
  }
  
  func testGivenCreatingNewFocus_WhenSavingContext_ThenNoError() {
    _ = createFocus()
    saveContext()
  }
  
  func testGivenUpdatingFocus_WhenSavingContext_ThenNoError() {
    let focus = createFocus()
    saveContext()
    focus.title = "Updating Focus"
    saveContext()
  }
  
  func testGivenDeletingFocus_WhenSavingContext_ThenNoError() {
    let focus = createFocus()
    saveContext()
    dataController.context.delete(focus)
    saveContext()
  }
    
  func testGivenToday_WhenUpdatingFocusTitle_ThenFocusTitleUpdated() {
    dataForToday(isFromLastDay: true)
    let today = Today(dataController)
    _ = today.loadData()
    XCTAssertEqual(today.goalTitle, "YESTERDAY")
    today.processData(title: "GOAL", order: -1, type: .goal)
    today.processData(title: "TASK 0", order: 0, type: .task)
    today.processData(title: "TASK 2", order: 2, type: .task)
    XCTAssertEqual(today.goalTitle, "GOAL")
    XCTAssertEqual(today.taskTitle(order: 0), "TASK 0")
    XCTAssertEqual(today.taskTitle(order: 2), "TASK 2")
    today.resetData()
    _ = today.loadData()
    XCTAssertEqual(today.goalTitle, "GOAL")
    XCTAssertEqual(today.taskTitle(order: 0), "TASK 0")
    XCTAssertEqual(today.taskTitle(order: 2), "TASK 2")
  }
  
  func testGivenToday_WhenRemoveFocus_ThenFocusRemoved() {
    dataForToday(isFromLastDay: true)
    let today = Today(dataController)
    _ = today.loadData()
    XCTAssertEqual(today.areAllTasksCompleted, false)
    XCTAssertEqual(today.isCompletedTask(order: 1), true)
    today.processData(title: "", order: 0, type: .task)
    today.processData(title: "", order: 2, type: .task)
    XCTAssertEqual(today.areAllTasksCompleted, true)
    XCTAssertEqual(today.isCompletedTask(order: 1), true)
    _ = today.loadData()
    XCTAssertEqual(today.areAllTasksCompleted, true)
    XCTAssertEqual(today.isCompletedTask(order: 1), true)
  }
  
  func testGivenToday_WhenUpdateDates_ThenFocusesGetTodayDates() {
    dataForToday(isFromLastDay: true)
    let today = Today(dataController)
    var isFromLastDay = today.loadData()
    XCTAssertEqual(isFromLastDay, true)
    today.updateDates()
    today.resetData()
    isFromLastDay = today.loadData()
    XCTAssertEqual(isFromLastDay, false)
  }
  
  func testGivenToday_WhenUserDeleteTodayFocuses_ThenRemoved() {
    dataForToday()
    let today = Today(dataController)
    _ = today.loadData()
    XCTAssertEqual(today.goalTitle, "TODAY")
    XCTAssertEqual(today.uncompletedTasksCount, 2)
    XCTAssertEqual(today.areAllTasksCompleted, false)
    today.deleteAll()
    var isThereAnyTask = self.isThereAnyTask(today: today)
    XCTAssertEqual(isThereAnyTask, false)
    XCTAssertEqual(today.goalTitle, nil)
    _ = today.loadData()
    isThereAnyTask = self.isThereAnyTask(today: today)
    XCTAssertEqual(isThereAnyTask, false)
    XCTAssertEqual(today.goalTitle, nil)
  }
  
  func testGivenToday_WhenLoadData_ThenGetTodayGoalsTasks() {
    dataForToday(isFromLastDay: true)
    dataForToday()
    let today = Today(dataController)
    let isFromLastDay = today.loadData()
    XCTAssertEqual(isFromLastDay, false)
    
    XCTAssertEqual(today.goalTitle, "TODAY")
    XCTAssertEqual(today.isGoalCompleted, false)
    XCTAssertEqual(today.areAllTasksCompleted, false)
    XCTAssertEqual(today.uncompletedTasksCount, 2)
    XCTAssertEqual(today.taskTitle(order: 0), "TODAY 0")
    XCTAssertEqual(today.taskTitle(order: 1), "TODAY 1")
    XCTAssertEqual(today.taskTitle(order: 2), "TODAY 2")
    XCTAssertEqual(today.isCompletedTask(order: 0), false)
    XCTAssertEqual(today.isCompletedTask(order: 1), true)
    XCTAssertEqual(today.isCompletedTask(order: 2), false)
  }
  
  func testGivenToday_WhenLoadData_ThenGetLastUncompletedFocuses() {
    dataForToday(isFromLastDay: true)
    let today = Today(dataController)
    let isFromLastDay = today.loadData()
    XCTAssertEqual(isFromLastDay, true)
    
    XCTAssertEqual(today.goalTitle, "YESTERDAY")
    XCTAssertEqual(today.isGoalCompleted, false)
    XCTAssertEqual(today.areAllTasksCompleted, false)
    XCTAssertEqual(today.uncompletedTasksCount, 2)
    XCTAssertEqual(today.taskTitle(order: 0), "YESTERDAY 0")
    XCTAssertEqual(today.taskTitle(order: 1), "YESTERDAY 1")
    XCTAssertEqual(today.taskTitle(order: 2), "YESTERDAY 2")
    XCTAssertEqual(today.isCompletedTask(order: 0), false)
    XCTAssertEqual(today.isCompletedTask(order: 1), true)
    XCTAssertEqual(today.isCompletedTask(order: 2), false)
  }
  
  func testGivenTodayTask_WhenSelect_ThenSelected() {
    dataForToday()
    let today = Today(dataController)
    _ = today.loadData()
    XCTAssertEqual(today.isCompletedTask(order: 0), false)
    XCTAssertEqual(today.isCompletedTask(order: 1), true)
    XCTAssertEqual(today.isCompletedTask(order: 2), false)
    XCTAssertEqual(today.areAllTasksCompleted, false)
    XCTAssertEqual(today.isGoalCompleted, false)
    today.task(isSelected: true, index: 0)
    XCTAssertEqual(today.isCompletedTask(order: 0), true)
    today.task(isSelected: true, index: 2)
    XCTAssertEqual(today.isCompletedTask(order: 2), true)
    XCTAssertEqual(today.areAllTasksCompleted, true)
    XCTAssertEqual(today.isGoalCompleted, true)
    
    today.task(isSelected: false, index: 1)
    XCTAssertEqual(today.isCompletedTask(order: 1), false)
    XCTAssertEqual(today.isGoalCompleted, false)
  }
  
  func testGivenTodayGoal_WhenSelect_ThenSelected() {
    dataForToday()
    let today = Today(dataController)
    _ = today.loadData()
    XCTAssertEqual(today.isGoalCompleted, false)
    XCTAssertEqual(today.isCompletedTask(order: 0), false)
    XCTAssertEqual(today.isCompletedTask(order: 1), true)
    XCTAssertEqual(today.isCompletedTask(order: 2), false)
    today.goal(isSelected: true)
    XCTAssertEqual(today.isGoalCompleted, true)
    XCTAssertEqual(today.isCompletedTask(order: 0), true)
    XCTAssertEqual(today.isCompletedTask(order: 1), true)
    XCTAssertEqual(today.isCompletedTask(order: 2), true)
  }
    
  let today = Date()
  
  private func dataForToday(isFromLastDay: Bool = false) {
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: self.today)
    let date = isFromLastDay ? yesterday : self.today
    let title = isFromLastDay ? "YESTERDAY" : "TODAY"
    let goal = Focus(context: dataController.context)
    goal.type = Type.goal.rawValue
    goal.isCompleted = false
    goal.order = -1
    goal.date = date
    goal.title = title
    focuses.append(goal)
    var task = Focus(context: dataController.context)
    task.type = Type.task.rawValue
    task.isCompleted = false
    task.order = 0
    task.date = date
    task.title = "\(title) 0"
    focuses.append(task)
    task = Focus(context: dataController.context)
    task.type = Type.task.rawValue
    task.isCompleted = true
    task.order = 1
    task.date = date
    task.title = "\(title) 1"
    focuses.append(task)
    task = Focus(context: dataController.context)
    task.type = Type.task.rawValue
    task.isCompleted = false
    task.order = 2
    task.date = date
    task.title = "\(title) 2"
    focuses.append(task)
    saveContext()
  }
  
  private func isThereAnyTask(today: Today) -> Bool {
    return today.uncompletedTasksCount != 0 || today.areAllTasksCompleted == true
  }
  
  private func createFocus() -> Focus {
    let focus = Focus(context: dataController.context)
    focus.title = "TEST"
    focus.date = Date()
    focus.order = -1
    focus.isCompleted = true
    focus.type = Type.goal.rawValue
    return focus
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
