//
//  PersistentContainer.swift
//  FocusOn
//
//  Created by Spencer Forrest on 23/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import Foundation
import CoreData

class PersistentContainer: NSPersistentContainer {
  
  override class func defaultDirectoryURL() -> URL {
    var directoryURL = super.defaultDirectoryURL()
    if let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
      let persistentStoreURL = libraryURL.appendingPathComponent(Constant.persistentStorePath, isDirectory: true)
      // Create "Persistent Store" folder in "Library/Application Support"
      createFolderIfNeeded(for: persistentStoreURL)
      directoryURL = persistentStoreURL
    }
    return directoryURL
  }
  
  private static func createFolderIfNeeded(for url: URL) {
    do {
      try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
      NSLog("Unable to create directory \(error.debugDescription)")
    }
  }
}
