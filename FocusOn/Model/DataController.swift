//
//  DataController.swift
//  FocusOn
//
//  Created by Spencer Forrest on 23/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import Foundation
import CoreData

class DataController {
  private let persistentContainer: NSPersistentContainer!
  
  var context: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  init(xcdatamodeldName name: String) {
    persistentContainer = PersistentContainer(name: name)
  }
  
  func load() {
    persistentContainer.loadPersistentStores {
      (description, error) in
      if let error = error {
        fatalError("Unable to load persistent stores: \(error)")
      }
    }
  }
}
