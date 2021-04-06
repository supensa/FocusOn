//
//  TabBarController.swift
//  FocusOn
//
//  Created by Spencer Forrest on 23/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit
import UserNotifications

class TabBarController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    // Load second tab bar item
    self.selectedIndex = 1
  }
  
  override func viewDidAppear(_ animated: Bool) {
    // Schedule (or remove) user notification
    scheduleLocalNotification(title: Constant.notificationTitle, body: Constant.notificationBody)
  }
  
  /// Schedule (or remove) user notification
  /// - Parameters:
  ///   - title: The localized title, containing the reason for the alert.
  ///   - body: The localized message to display in the notification alert.
  func scheduleLocalNotification(title: String?, body: String?) {
    let identifier = Constant.notificationIdentifier
    let notificationCenter = UNUserNotificationCenter.current()
    // remove previously scheduled notifications
    notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    if let newTitle = title, let newBody = body {
      // create content
      let content = UNMutableNotificationContent()
      content.title = newTitle
      content.body = newBody
      content.sound = UNNotificationSound.default
      // Convert hours to second
      let timeInterval = hoursToSecond(Constant.notificationHourInterval)
      // create trigger
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
      // create request
      let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
      // schedule notification
      notificationCenter.add(request, withCompletionHandler: nil)
    }
  }
  
  /// Converts hours to seconds
  /// - Parameter hour: hour as integer
  /// - Returns: time interval in second
  private func hoursToSecond(_ hour: Int) -> TimeInterval{
    return TimeInterval(hour * 3600)
  }
}
