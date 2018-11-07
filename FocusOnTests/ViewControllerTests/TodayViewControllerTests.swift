//
//  TodayViewControllerTests.swift
//  FocusOnTests
//
//  Created by Spencer Forrest on 03/11/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import XCTest
import CoreData
@testable import FocusOn

class TodayViewControllerTests: XCTestCase {
  
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
  
  func testGivenUIView_WhenLookingForFirstResponder_ThenGetFirstResponder() {
    var window: UIView? = UIWindow()
    let mainView = View()
    let firstContainerView = View()
    let secondContrainerView = View()
    let segmentControl = View()
    let button = View()
    let label = View()
    label.title = "first responder"
    label.becomeFirstResponder()
    
    secondContrainerView.addSubview(button)
    secondContrainerView.addSubview(label)
    firstContainerView.addSubview(segmentControl)
    mainView.addSubview(firstContainerView)
    mainView.addSubview(secondContrainerView)
    window?.addSubview(mainView)
    
    let firstResponder = mainView.firstResponder as! View
    XCTAssertTrue(firstResponder.isFirstResponder)
    XCTAssertEqual(firstResponder.title, "first responder" )
    window = nil
  }
  
  func testGivenTodayViewDidLoad_WhenTextViewDidFinishEditing_ThenUpdateModel() {
    instantiateDataForToday()
    saveContext()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let todayViewController = storyboard.instantiateViewController(withIdentifier: "TodayViewController") as! TodayViewController
    todayViewController.setupDataController(dataController)
    if todayViewController.view == nil {
      XCTFail("View did not Load")
    }
    todayViewController.viewDidAppear(false)
    let tableView: UITableView = todayViewController.tableView
    let goalCell = todayViewController.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! TableViewCell
    let task0Cell = todayViewController.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1)) as! TableViewCell
    _ = todayViewController.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 1))
    _ = todayViewController.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 1))
    let model = todayViewController.model
    XCTAssertEqual(model?.goalTitle, "test")
    goalCell.textView.text = "GOAL"
    todayViewController.textViewDidFinishEditing(cell: goalCell, tag: -1)
    XCTAssertEqual(model?.goalTitle, "GOAL")
    XCTAssertEqual(model?.taskTitle(order: 0), "task0")
    task0Cell.textView.text = "NEW TASK"
    todayViewController.textViewDidFinishEditing(cell: task0Cell, tag: 0)
    XCTAssertEqual(model?.taskTitle(order: 0), "NEW TASK")
  }
  
  func testGivenTodayViewDidLoaded_WhenDeselectingRow_ThenUpdateModel() {
    instantiateDataForToday()
    saveContext()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let todayViewController = storyboard.instantiateViewController(withIdentifier: "TodayViewController") as! TodayViewController
    todayViewController.setupDataController(dataController)
    _ = todayViewController.view
    let tableView: UITableView = todayViewController.tableView
    _ = todayViewController.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
    _ = todayViewController.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))
    _ = todayViewController.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 1))
    _ = todayViewController.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 1))
    todayViewController.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
    let today: Today = todayViewController.model
    XCTAssertEqual(today.isGoalCompleted, true)
    XCTAssertEqual(today.isCompletedTask(order: 0), true)
    XCTAssertEqual(today.isCompletedTask(order: 1), true)
    XCTAssertEqual(today.isCompletedTask(order: 2), true)
    todayViewController.tableView(tableView, didDeselectRowAt: IndexPath(row: 0, section: 0))
    todayViewController.tableView(tableView, didDeselectRowAt: IndexPath(row: 0, section: 1))
    todayViewController.tableView(tableView, didDeselectRowAt: IndexPath(row: 1, section: 1))
    todayViewController.tableView(tableView, didDeselectRowAt: IndexPath(row: 2, section: 1))
    XCTAssertEqual(today.isGoalCompleted, false)
    XCTAssertEqual(today.isCompletedTask(order: 0), false)
    XCTAssertEqual(today.isCompletedTask(order: 1), false)
    XCTAssertEqual(today.isCompletedTask(order: 2), false)
  }
  
  func testGivenTodayViewDidLoaded_WhenSelectingRow_ThenUpdateModel() {
    instantiateDataForToday()
    saveContext()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let todayViewController = storyboard.instantiateViewController(withIdentifier: "TodayViewController") as! TodayViewController
    todayViewController.setupDataController(dataController)
    _ = todayViewController.view
    let tableView: UITableView = todayViewController.tableView
    _ = todayViewController.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
    _ = todayViewController.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))
    _ = todayViewController.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 1))
    _ = todayViewController.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 1))
    let today: Today = todayViewController.model
    XCTAssertEqual(today.isCompletedTask(order: 2), false)
    todayViewController.tableView(tableView, didSelectRowAt: IndexPath(row: 2, section: 1))
    XCTAssertEqual(today.isCompletedTask(order: 2), true)
    todayViewController.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
    XCTAssertEqual(today.isGoalCompleted, true)
    XCTAssertEqual(today.isCompletedTask(order: 0), true)
    XCTAssertEqual(today.isCompletedTask(order: 1), true)
    XCTAssertEqual(today.isCompletedTask(order: 2), true)
  }
  
  private func instantiateDataForToday() {
    let date = Date()
    let goal = Focus(context: dataController.context)
    goal.title = "test"
    goal.date = date
    goal.order = -1
    goal.isCompleted = false
    goal.type = Type.goal.rawValue
    
    let task0 = Focus(context: dataController.context)
    task0.title = "task0"
    task0.date = date
    task0.order = 0
    task0.isCompleted = true
    task0.type = Type.task.rawValue
    
    let task1 = Focus(context: dataController.context)
    task1.title = "task1"
    task1.date = date
    task1.order = 1
    task1.isCompleted = false
    task1.type = Type.task.rawValue
    
    let task2 = Focus(context: dataController.context)
    task2.title = "task2"
    task2.date = date
    task2.order = 2
    task2.isCompleted = false
    task2.type = Type.task.rawValue
  }
  
  private func saveContext() {
    do {
      try dataController.saveContext()
    } catch {
      let error = error as NSError
      XCTFail(error.debugDescription)
    }
  }
  
  // This class is needed to test 'First responder'
  private class View: UIView {
    var title = "Not First Responder"
    override var canBecomeFirstResponder: Bool {
      return true
    }
    
    override var canResignFirstResponder: Bool {
      return true
    }
  }
}
