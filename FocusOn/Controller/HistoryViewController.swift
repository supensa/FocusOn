//
//  HistoryViewController.swift
//  FocusOn
//
//  Created by Spencer Forrest on 23/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, ViewControllerProtocol {
  
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var completionLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  var dataController: DataController!
  private var historyDataManager: HistoryDataManager!
  var fetchedResultsController: NSFetchedResultsController<Focus>!
  
  private var lastContentOffset: CGFloat = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    historyDataManager = HistoryDataManager(dataController)
    tableView.delegate = self
    tableView.dataSource = self
    setupCompletionLabelBorder()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    fetchedResultsController = nil
    tableView.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    fetchedResultsController = historyDataManager.historyFetchResultsController()
    tableView.reloadData()
    updateDateLabel()
    updateCompletionLabel()
  }
  
  private func setupCompletionLabelBorder() {
    let bottomBorder = CALayer()
    bottomBorder.backgroundColor = UIColor.gray.cgColor
    bottomBorder.frame = CGRect(x: 0, y: self.completionLabel.frame.height - 1.5,
                                width: self.view.frame.size.width,
                                height: 1.5)
    self.completionLabel.layer.addSublayer(bottomBorder)
  }
}

// -------------------------------------------------------------------------
// MARK: -  TableView datasource
extension HistoryViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    if fetchedResultsController == nil { return 0 }
    return fetchedResultsController.sections?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if fetchedResultsController == nil { return 0 }
    return fetchedResultsController.sections?[section].numberOfObjects ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if fetchedResultsController == nil { return UITableViewCell() }
    let focus: Focus = fetchedResultsController.object(at: indexPath)
    
    if let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCellId") as? HistoryTableViewCell {
      cell.label.text = focus.isCompleted ? Constant.checkmark : ""
      cell.textView.text = focus.title!
      if focus.type == Type.goal.rawValue {
        cell.textView?.font = cell.textView?.font?.withSize(30)
      } else {
        cell.textView?.font = cell.textView?.font?.withSize(15)
      }
      return cell
    }
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "default"
  }
}

// -------------------------------------------------------------------------
// MARK: - Scroll view delegate
extension HistoryViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let focus: Focus  = fetchedResultsController.sections?[section].objects?.first as! Focus
    let text = dateString(date: focus.date!)
    return header(text: text)
  }
  
  private func header(text: String?) -> UIView {
    let view = UIView()
    let label = UILabel()
    label.text = text
    view.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    return view
  }
  
  private func dateString(date: Date) -> String {
    // Get the current calendar with local time zone
    var calendar = Calendar.current
    calendar.timeZone = NSTimeZone.local
    
    // Get beginning & end
    let day = calendar.startOfDay(for: date) // eg. 2016-10-10 00:00:00
    let today = calendar.startOfDay(for: Date())
    
    return today == day ? Constant.today : formatDateToString(date: day)
  }
  
  private func formatDateToString(date: Date, format: String = Constant.sectionDateFormat) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.timeZone = TimeZone.current
    return dateFormatter.string(from: date)
  }
}

// -------------------------------------------------------------------------
// MARK: - Scroll view delegate
extension HistoryViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let scrollDirection = scrollingDirection(scrollView)
    
    updateDateLabel(direction: scrollDirection)
    updateCompletionLabel(direction: scrollDirection)
  }
  
  private func scrollingDirection(_ scrollView: UIScrollView) -> ScrollDirection {
    var scrollDirection = ScrollDirection.none
    
    if (self.lastContentOffset > scrollView.contentOffset.y) {
      scrollDirection = .up
    } else if (self.lastContentOffset < scrollView.contentOffset.y) {
      scrollDirection = .down
    }
    
    self.lastContentOffset = scrollView.contentOffset.y
    
    return scrollDirection
  }
  
  private func updateDateLabel(direction: ScrollDirection = .up) {
    guard let date = dateFromVisibleCell(direction: direction) else { return }
    let dateTitle = formatDateToString(date: date, format: Constant.titleDateFormat)
    self.dateLabel.text = dateTitle
  }
  
  private func dateFromVisibleCell(direction: ScrollDirection) -> Date? {
    let potentialCell = direction == .down ? tableView.visibleCells.last : tableView.visibleCells.first
    guard let cell = potentialCell as? HistoryTableViewCell
      else { return nil}
    guard let indexPath = tableView.indexPath(for: cell)
      else { return nil }
    let focus = fetchedResultsController.object(at: indexPath)
    return focus.date
  }
  
  private func updateCompletionLabel(direction: ScrollDirection = .up) {
    let goals = getMonthlyGoals(direction: direction)
    let total = goals?.count ?? 0
    let completed = goals?.filter{ $0.isCompleted == true }.count ?? 0
    
    let sentence = "\(completed) out of \(total) goals completed"
    completionLabel.text = sentence
  }
  
  private func getMonthlyGoals(direction: ScrollDirection) -> [Focus]? {
    guard let date = dateFromVisibleCell(direction: direction) else { return nil}
    let month = monthString(from: date)
    let year = yearString(from: date)
    let results: [Focus]? = fetchedResultsController.fetchedObjects
    let goals = results?.filter {
      guard let date = $0.date else { return false }
      guard let type = $0.type else { return false }
      let isGoal = type == Type.goal.rawValue
      let isSameMonth = self.monthString(from: date) == month
      let isSameYear = self.yearString(from: date) == year
      return isGoal && isSameMonth && isSameYear
    }
    return goals
  }
  
  private func monthString(from date: Date) -> String {
    return formatDateToString(date: date, format: Constant.monthDateFormat)
  }
  
  private func yearString(from date: Date) -> String {
    return formatDateToString(date: date, format: Constant.yearDateFormat)
  }
}
