//
//  Today.swift
//  FocusOn
//
//  Created by Spencer Forrest on 18/10/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import Foundation
import CoreData

class Today {
  var goalTitle: String? {
    return goal?.title
  }
  var isGoalCompleted: Bool {
    return goal?.isCompleted ?? false
  }
  var areAllTasksCompleted: Bool {
    return tasks.count == countCompletedTasks() && tasks.count != 0
  }
  var uncompletedTasksCount: Int {
    return tasks.count - countCompletedTasks()
  }
  private var goal: Focus?
  private var tasks = Dictionary<Int, Focus>()
  private var results = [Focus]()
  private let dataController: DataController!
  
  init(_ dataController: DataController) {
    self.dataController = dataController
  }
  
  /// Retrieve a goal and its tasks
  ///
  /// - Returns: True if data is from previous uncompleted Goal
  func loadData() -> Bool {
    // Request today's goal if any
    results = self.fetchResultsController(date: Date()).fetchedObjects ?? []
    var isFromLastDay = false
    // if no goal today
    if results.isEmpty {
      // Request previous day's unachieved goal
      if let goal = self.requestLastUncompletedGoal() {
        isFromLastDay = true
        // Request previous day's unachieved goal and its tasks
        let previousDate = goal.date!
        results = self.fetchResultsController(date: previousDate).fetchedObjects ?? []
      }
    }
    // Filter out the the Goal
    goal = results.filter { return ($0 as AnyObject).type == Type.goal.rawValue }.first
    // Filter out in "order" the Tasks
    results = results.filter { return ($0 as AnyObject).type == Type.task.rawValue }
    for result in results {
      let index = Int(result.order)
      tasks[index] = result
    }
    if isFromLastDay {
      if let goal = goal { results.append(goal) }
    }
    return isFromLastDay
  }
  
  /// Return task's title
  /// - Parameter order: Identify the task (from 0 to 2)
  /// - Returns: Returns the title or nil if the task does not exist
  func taskTitle(order: Int) -> String? {
    return tasks[order]?.title
  }
  
  /// Check whether the task is completed
  /// - Parameter order: Identify the task (from 0 to 2)
  /// - Returns: True only if it exists and is completed
  func isCompletedTask(order: Int) -> Bool {
    return tasks[order]?.isCompleted ?? false
  }
  
  /// Set completion status of goal
  /// - Parameters:
  ///   - isSelected: True to set as "selected"
  ///   - errorHandler: Errorhandler in case the context cannot save the changes
  func goal(isSelected: Bool, errorHandler: (()->())? = nil) {
    goal?.isCompleted = isSelected
    if isSelected {
      for (_,task) in tasks {
        update(focus: task, date: nil, type: nil, title: nil, order: nil, isCompleted: isSelected, errorHandler: errorHandler)
      }
    } else {
      save(errorHandler)
    }
  }
  
  /// Set completion status of task
  /// - Parameters:
  ///   - isSelected: True to set as "selected"
  ///   - index: Identify the task (from 0 to 2)
  ///   - errorHandler: Errorhandler in case the context cannot save the changes
  func task(isSelected: Bool, index: Int, errorHandler: (()->())? = nil) {
    tasks[index]?.isCompleted = isSelected
    if !isSelected {
      goal?.isCompleted = false
    } else if areAllTasksCompleted {
      goal?.isCompleted = true
    }
    save(errorHandler)
  }
  
  
  /// Reset the model data in memory
  func resetData() {
    goal = nil
    tasks.removeAll()
  }
  
  /// Delete the in memory goal and its tasks from persistence store and from memory
  /// - Parameter errorHandler: Errorhandler in case the context cannot save the changes
  func deleteAll(errorHandler: (()->())? = nil){
    guard goal != nil || tasks.count > 0
      else { return }
    if let goal = goal {
      dataController.context.delete(goal)
    }
    for (_, task) in tasks {
      dataController.context.delete(task)
    }
    resetData()
    save(errorHandler)
  }
  
  /// Update to today's date for the in memory goal and its tasks
  /// - Parameter errorHandler: Errorhandler in case the context cannot save the changes
  func updateDates(errorHandler: (()->())? = nil) {
    let date = Date()
    updateAll(date: date, type: nil, title: nil, order: nil, isCompleted: nil, errorHandler: errorHandler)
  }
  
  /// Remove or update a specific Focus.
  ///
  /// If title is nil delete the focus otherwise update its title and date.
  /// - Parameters:
  ///   - title: Focus'title
  ///   - order: Identify the task (from 0 to 2)
  ///   - type: Goal or Task
  ///   - errorHandler: Errorhandler in case the context cannot save the changes
  func processData(title: String, order: Int, type: Type, errorHandler: (()->())? = nil) {
    if title == "" {
      processDataRemoval(type: type, order: order, errorHandler: errorHandler)
    } else {
      processDataUpdate(type: type, title: title, order: order, errorHandler: errorHandler)
    }
  }
  
  /// Delete a sepcific in memory task. Delete all in memory focuses if goal is deleted
  /// - Parameters:
  ///   - type: Goal or Task
  ///   - order: Identify the task (from 0 to 2)
  ///   - errorHandler: Errorhandler in case the context cannot save the changes
  private func processDataRemoval(type: Type, order: Int, errorHandler: (()->())? = nil) {
    if type == .goal {
      deleteAll()
    } else {
      if let focus = tasks[order] {
        delete(focus: focus, order: order, errorHandler: errorHandler)
      }
    }
  }
  
  /// Update all in memory Focuses and save them into persistent store.
  ///
  /// Only update not nil parameters. Date update is mandatory.
  /// - Parameters:
  ///   - date: New date
  ///   - type: New type
  ///   - title: New title
  ///   - order: New order (index mainly for tasks)
  ///   - isCompleted: True if completed
  ///   - errorHandler: Errorhandler in case the context cannot save the changes
  private func updateAll(date: Date, type: Type? = nil , title: String? = nil,
                 order: Int? = nil, isCompleted: Bool? = nil, errorHandler: (()->())? = nil){
    if goal != nil {
      update(focus: goal!, date: date, type: type, title: title, order: order, isCompleted: isCompleted, errorHandler: errorHandler)
    }
    for (_,task) in tasks {
      update(focus: task, date: date, type: type, title: title, order: order, isCompleted: isCompleted, errorHandler: errorHandler)
    }
  }
  
  /// Update this focus into persistent store
  ///
  /// - Parameters:
  ///   - focus: focus to update
  ///   - date: date of update
  ///   - type: type of focus (goal or task)
  ///   - title: title of focus
  ///   - order: index mainly to identify tasks
  ///   - isCompleted: completion of focus
  ///   - errorHandler: closure in case saving with CoreData fails
  private func update(focus: Focus, date: Date?, type: Type? = nil , title: String? = nil,
              order: Int? = nil, isCompleted: Bool? = nil, errorHandler: (()->())? = nil) {
    if let date = date {
      focus.date = date
    }
    if let type = type {
      focus.type = type.rawValue
    }
    if let title = title {
      focus.title = title
    }
    if let order = order {
      focus.order = Int16(order)
    }
    if let isCompleted = isCompleted {
      focus.isCompleted = isCompleted
    }
    save(errorHandler)
  }
  
  /// Remove focus from persistent store.
  /// - Parameters:
  ///     - focus: focus to be removed
  ///     - order: index mainly to identify tasks
  ///     - errorHandler: closure in case saving with CoreData fails
  private func delete(focus: Focus, order: Int, errorHandler: (()->())? = nil) {
    dataController.context.delete(focus)
    if focus.type == Type.goal.rawValue { goal = nil }
    if focus.type == Type.task.rawValue { tasks[order] = nil}
    save(errorHandler)
  }
  
  /// Create, if needed, or update a focus.
  ///
  /// It cannot create a Task if there is no Goal set.
  ///
  /// - Parameters:
  ///   - type: type of focus (goal or task)
  ///   - title: title of focus
  ///   - order: order of task
  ///   - errorHandler: closure in case saving with CoreData fails
  private func processDataUpdate(type: Type, title: String, order: Int, errorHandler: (()->())? = nil) {
    if type == .task && goal == nil { return }
    var focus: Focus
    var isCompleted: Bool
    // Create new Focus if needed
    if type == .goal && goal == nil || type == .task && tasks[order] == nil {
      focus = Focus(context: dataController.context)
      isCompleted = false
      goal?.isCompleted = false
    } else {
      focus = type == .goal ? goal! : tasks[order]!
      isCompleted = focus.isCompleted
    }
    update(focus: focus, date: Date(), type: type, title: title,
           order: order, isCompleted: isCompleted, errorHandler: errorHandler)
    if type == .goal {
      goal = focus
    } else {
      tasks[order] = focus
    }
    updateDates()
  }
  
  /// Return the number of completed tasks
  ///
  /// - Returns: Count of completed tasks
  private func countCompletedTasks() -> Int {
    return tasks.filter {
      let result = $1.isCompleted
      return result
      }.count
  }
    
  private func save(_ errorHandler: (()->())? = nil) {
    do {
      try dataController.saveContext()
    } catch {
      if let errorHandler = errorHandler {
        errorHandler()
      }
    }
  }
  
  /// Request a goal and its tasks for a specifice date
  ///
  /// - Parameter date: goal and tasks associated date
  /// - Returns: NSFetchedResultsController containing goal and its tasks
  private func fetchResultsController(date: Date) -> NSFetchedResultsController<Focus> {
    let fetchRequest: NSFetchRequest<Focus> = Focus.fetchRequest()
    let typeSortDescriptor = NSSortDescriptor(key: "type", ascending: false)
    fetchRequest.sortDescriptors = [typeSortDescriptor]
    let predicate = dataController.datePredicate(from: date)
    fetchRequest.predicate = predicate
    let fetchedResultsController: NSFetchedResultsController<Focus> =
      NSFetchedResultsController(fetchRequest: fetchRequest,
                                 managedObjectContext: dataController.context,
                                 sectionNameKeyPath: nil,
                                 cacheName: nil)
    try? fetchedResultsController.performFetch()
    return fetchedResultsController
  }
  
  /// Request the last uncompleted Goal
  ///
  /// - Returns: last uncompleted goal if any
  private func requestLastUncompletedGoal() -> Focus? {
    let fetchRequest: NSFetchRequest<Focus> = Focus.fetchRequest()
    let sortDescriptior = NSSortDescriptor(key: "date", ascending: false)
    let goalPredicate = NSPredicate(format: "type = %@", Type.goal.rawValue)
    let completedPredicate = NSPredicate(format: "isCompleted = %@", NSNumber(value: false))
    let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [goalPredicate, completedPredicate])
    fetchRequest.sortDescriptors = [sortDescriptior]
    fetchRequest.predicate = compoundPredicate
    fetchRequest.fetchLimit = 1
    var results = [Focus]()
    if let objects = try? dataController.context.fetch(fetchRequest) {
      results = objects
    }
    return results.first
  }
}
