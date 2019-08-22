//
//  DummyData.swift
//  FocusOn
//
//  Created by Spencer Forrest on 28/10/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import Foundation
import CoreData

class DummyData {
  static func generate(context: NSManagedObjectContext) {
    let dates = createDates()
    generateFocuses(dates: dates, context: context)
  }
  
  static private func createDates() -> [String] {
    var dates = [String]()
    let date = Date()
    let calendar = Calendar.current
    let currentMonth = calendar.component(.month, from: date)
    let year = calendar.component(.year, from: date)
    let month = 1
    dates.append("\(year)-\(month)-02 00:00:00")
    dates.append("\(year)-\(month)-03 00:00:00")
    dates.append("\(year)-\(month)-04 00:00:00")
    dates.append("\(year)-\(currentMonth)-01 00:00:00")
    dates.append("\(year)-\(currentMonth)-02 00:00:00")
    dates.append("\(year)-\(currentMonth)-06 00:00:00")
    return dates
  }
  
  static private func generateFocuses(dates: [String], context: NSManagedObjectContext) {
    for stringDate in dates {
      if let date = createDate(from: stringDate) {
        let isCompleted = ramdomBoolean()
        let title = getTitle(for: .goal)
        generateFocus(title: title,
                      type: .goal,
                      order: -1,
                      date: date,
                      isCompleted: isCompleted,
                      context: context)
        generateTasks(mustBeCompleted: isCompleted,
                      date: date,
                      context: context)
      }
    }
  }
  
  static private func generateTasks(mustBeCompleted: Bool,
                                    date: Date,
                                    context: NSManagedObjectContext) {
    let totalTasks = Int.random(in: 0...2)
    for order in 0...totalTasks {
      let isCompleted = mustBeCompleted ? true : ramdomBoolean()
      let title = getTitle(for: .task)
      generateFocus(title: title,
                    type: .task,
                    order: Int16(order),
                    date: date,
                    isCompleted: isCompleted,
                    context: context)
    }
  }
  
  static private let titles = [
    "My ",
    "Super ",
    "Awesome ",
    "Languistic ",
    "Heroic ",
    "Terrific "
  ]
  
  static private func getTitle(for type: Type) -> String {
    let index = Int.random(in: 0...titles.count - 1)
    let string = type == .goal ? "goal" : "task"
    return titles[index] + string
  }
  
  static private func ramdomBoolean() -> Bool {
    return Int.random(in: 0...1) == 1
  }
  
  static private func generateFocus(title: String,
                                    type: Type,
                                    order: Int16,
                                    date: Date,
                                    isCompleted: Bool,
                                    context: NSManagedObjectContext) {
    let focus = Focus(context: context)
    focus.title = title
    focus.type = type.rawValue
    focus.order = order
    focus.date = date
    focus.isCompleted = isCompleted
    do {
      try context.save()
    } catch {
      let error = error as NSError
      fatalError(error.debugDescription)
    }
  }
  
  static private func createDate(from string: String) -> Date? {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)!
    formatter.dateFormat = Constant.defaultDateFormat
    return formatter.date(from: string)
  }
}
