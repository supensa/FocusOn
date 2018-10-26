//
//  TodayDataManager.swift
//  FocusOn
//
//  Created by Spencer Forrest on 18/10/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import Foundation
import CoreData

class TodayDataManager {
  private let dataController: DataController!
  
  init(_ dataController: DataController) {
    self.dataController = dataController
  }
  
  /// Request a goal and its tasks for a specifice date
  ///
  /// - Parameter date: goal and tasks associated date
  /// - Returns: goal and tasks if any
  func fetchResultsController(date: Date, errorHandler: (()->())? = nil) -> NSFetchedResultsController<Focus> {
    let fetchRequest: NSFetchRequest<Focus> = Focus.fetchRequest()
    let typeSortDescriptor = NSSortDescriptor(key: "type", ascending: false)
    fetchRequest.sortDescriptors = [typeSortDescriptor]
    let predicate = dataController.datePredicate(from: date)
    fetchRequest.predicate = predicate
    let fetchedResultsController: NSFetchedResultsController<Focus> = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: nil)
    try? fetchedResultsController.performFetch()
    return fetchedResultsController
  }
  
  /// Request the last unachieved Goal
  ///
  /// - Returns: last uncompleted goal if any
  func requestLastUncompletedGoal(errorHandler: (()->())? = nil) -> Focus? {
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
