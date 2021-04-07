//
//  DataController.swift
//  FocusOn
//
//  Created by Spencer Forrest on 23/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/// Setup and manage the core data stack
class DataController {
  /// When 'DataController' is initialized in AppDelegate
  /// then "static var model" updates to current NSManagedOjectModel.
  /// This is needed for Unit Testing 'DataController'
  /// since we need to use the same NSManagedObjectModel in memory.
  static var model: NSManagedObjectModel = NSManagedObjectModel()
  
  private var persistentContainer: NSPersistentContainer!
  
  /// The managed object context associated with the main queue.(read-only)
  var context: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  /// Initialize the core data stack
  /// - Parameters:
  ///   - name: The name used by the persistent container.
  ///   - managedObjectModel: A programmatic representation of the .xcdatamodeld file describing your objects.
  ///   - persistentStoreDescription: A description object used to create and load a persistent store.
  init(xcdatamodeldName name: String,
       managedObjectModel: NSManagedObjectModel? = nil,
       persistentStoreDescription: NSPersistentStoreDescription? = nil ) {
    if let managedObjectModel = managedObjectModel {
      persistentContainer = PersistentContainer.init(name: name, managedObjectModel: managedObjectModel)
    } else {
      persistentContainer = PersistentContainer.init(name: name)
    }
    if let storeDescription = persistentStoreDescription {
       let persistentStoreDescription = NSPersistentStoreDescription()
      persistentStoreDescription.type = storeDescription.type
      persistentContainer.persistentStoreDescriptions = [persistentStoreDescription]
    }
    // Update "static var model"
    DataController.model = persistentContainer.managedObjectModel
  }
  
  func load() {
    persistentContainer.loadPersistentStores {
      (description, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
  }
  
  /// Make sure context changed before saving
  ///
  /// - Throws: Exception if context could not save
  func saveContext() throws {
    if context.hasChanges {
       try self.context.save()
    }
  }
}

// -------------------------------------------------------------------------
// MARK: - Helping Functions
extension DataController {
  /// Create a predicate for a specific date
  ///
  /// - Parameters:
  ///   - date: Beginning date
  ///   - endDate: Ending date
  /// - Returns: Compound predicate
  func datePredicate(from date: Date = Date(), to endDate: Date? = nil) -> NSCompoundPredicate {
    // Get the current calendar with local time zone
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current
    
    // Get beginning and end
    let dateFrom = calendar.startOfDay(for: date) // eg. 2018-10-10 00:00:00 (for current Time zone but different for UTC +0000)
    let endDate = endDate == nil ? calendar.date(byAdding: .day, value: 1, to: dateFrom) : endDate
    var dateTo = dateFrom
    if let date = endDate {
      dateTo = date
    }
    // Note: Times are printed in UTC. UTC times can be converted to local time
    // Set predicates
    let dateFromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
    let dateToPredicate = NSPredicate(format: "date < %@", dateTo as NSDate)
    return NSCompoundPredicate(andPredicateWithSubpredicates: [dateFromPredicate, dateToPredicate])
  }
}
  

