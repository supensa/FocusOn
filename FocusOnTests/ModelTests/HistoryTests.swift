//
//  HistoryTests.swift
//  FocusOnTests
//
//  Created by Spencer Forrest on 03/11/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import XCTest
import CoreData
@testable import FocusOn

class HistoryTests: XCTestCase {

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
  
  func testGivenHistory_WhenFecthingData_ThenDataFetched() {
    dataForToday()
    let history = History(dataController)
    let fetchedResultsController = history.historyFetchResultsController()
    let goal = fetchedResultsController.fetchedObjects?.filter({
      (focus) -> Bool in
      focus.type == Type.goal.rawValue
    }).first
    let tasks = fetchedResultsController.fetchedObjects?.filter({
      (focus) -> Bool in
      focus.type == Type.task.rawValue
    })
    XCTAssertNotNil(goal)
    XCTAssertNotNil(tasks)
    XCTAssertEqual(tasks?.count, 3)
    var count = 0
    for task in tasks ?? [] {
      let isCompleted = count == 1 ? true : false
      XCTAssertEqual(task.title, "TODAY \(count)")
      XCTAssertEqual(task.order, Int16(count))
      XCTAssertEqual(task.date, self.today)
      XCTAssertEqual(task.isCompleted, isCompleted)
      XCTAssertEqual(task.type, Type.task.rawValue)
      count += 1
    }
    XCTAssertEqual(goal?.title, "TODAY")
    XCTAssertEqual(goal?.order, -1)
    XCTAssertEqual(goal?.date, self.today)
    XCTAssertEqual(goal?.isCompleted, false)
    XCTAssertEqual(goal?.type, Type.goal.rawValue)
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
  
  private func saveContext() {
    do {
      try dataController.saveContext()
    } catch {
      let error = error as NSError
      XCTFail(error.debugDescription)
    }
  }
}
