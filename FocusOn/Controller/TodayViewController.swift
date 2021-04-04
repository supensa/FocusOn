//
//  TodayViewController.swift
//  FocusOn
//
//  Created by Spencer Forrest on 23/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit
import CoreData

class TodayViewController: ViewController {
  internal var model: Today!
  @IBOutlet weak var tableView: UITableView!
  private var isFromLastDay: Bool!
  private var accessoryView: UIView!
  private var saveButton: UIButton!
  private var clearButton: UIButton!
  private var deleteAllButton: UIButton!
  private var goalHeaderLabel: UILabel!
  private var taskHeaderLabel: UILabel!
  private var triggerGoalAnimation = false
  private var triggerTaskAnimation = false
  private var taskUnchecked = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    model = Today(self.dataController)
    isFromLastDay = model.loadData()
    tableViewDelegation()
    hideKeyboardWhenTappedAround()
    registerForKeyboardNotifications()
    setupAccessoryView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if isFromLastDay {
      askConfirmation()
      isFromLastDay = false
    }
  }
  
  private func tableViewDelegation() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  private var alertWindow: UIWindow? = UIWindow()
  
  // Create a new UIWindow make it key and visible to present a UIAlertController
  private func show(_ alertViewController: UIAlertController) {
    let screen = UIScreen.main
    alertWindow = UIWindow(frame: screen.bounds)
    alertWindow?.rootViewController = UIViewController()
    alertWindow?.makeKeyAndVisible()
    alertWindow?.rootViewController?.present(alertViewController, animated: true)
  }
  
  // Remove the new UIWindow
  private func removeAlertWindow() {
    alertWindow = nil
  }
  
  /**
   Create a UIAlertController and show it to the user.
   Ask wether the user wants to keep the last uncompleted Goal and its related tasks
   as today's new Goal and tasks
  **/
  private func askConfirmation() {
    let title = Constant.confirmationTitle
    let message = Constant.confirmationMessage
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    let yesAction = UIAlertAction(title: "Yes", style: .default)  {
      (_: UIAlertAction) in
      self.yesAction()
      self.removeAlertWindow()
    }
    let noAction = UIAlertAction(title: "No", style: .destructive){
      (_: UIAlertAction) in
      self.noAction()
      self.removeAlertWindow()
    }
    
    alertController.addAction(yesAction)
    alertController.addAction(noAction)
    
    if let popoverController = alertController.popoverPresentationController {
      popoverController.sourceView = self.tableView
      popoverController.sourceRect = CGRect(x: self.tableView.bounds.midX, y: self.tableView.bounds.maxY - 5, width: 0, height: 0)
      popoverController.permittedArrowDirections = [UIPopoverArrowDirection.down]
    }
    show(alertController)
  }
  
  private func noAction() {
    self.model.resetData()
    self.tableView.reloadData()
  }
  
  private func yesAction() {
    // Update (tasks and goal) dates to today
    self.model.updateDates() { self.showSavingErrorToUser() }
  }
  
  /// Error message concerning the failure to save data.
  private func showSavingErrorToUser() {
    let message =  Constant.contextSavingErrorMessage
    let alertController = UIAlertController(title: Constant.contextSavingErrorTitle,
                                            message: message,
                                            preferredStyle: .alert)
    let actionOk = UIAlertAction(title: "Ok", style: .default)
    alertController.addAction(actionOk)
    self.present(alertController, animated: false, completion: nil)
  }
}

// -------------------------------------------------------------------------
// MARK: - Accesory View setup
// Setup "inputAccessoryView" that will be above the keyboard.
extension TodayViewController {
  private func setupAccessoryView() {
    instantiateAccessoryView()
    
    setupSaveButton()
    setupClearButton()
    setupDeleteAllButton()
    
    accessoryView.addSubview(saveButton)
    accessoryView.addSubview(clearButton)
    accessoryView.addSubview(deleteAllButton)
    
    setupAccessoryViewConstraints()
  }
  
  private func instantiateAccessoryView() {
    accessoryView = UIView(frame: .zero)
    accessoryView.backgroundColor = .white
    accessoryView.alpha = 1
    accessoryView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 45)
  }
  
  private func setupAccessoryViewConstraints() {
    accessoryView.translatesAutoresizingMaskIntoConstraints = false
    saveButton.translatesAutoresizingMaskIntoConstraints = false
    clearButton.translatesAutoresizingMaskIntoConstraints = false
    deleteAllButton.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      deleteAllButton.centerXAnchor.constraint(equalTo: accessoryView.centerXAnchor),
      deleteAllButton.centerYAnchor.constraint(equalTo: accessoryView.centerYAnchor),
      clearButton.leadingAnchor.constraint(equalTo: accessoryView.leadingAnchor, constant: 16),
      clearButton.centerYAnchor.constraint(equalTo: accessoryView.centerYAnchor),
      saveButton.trailingAnchor.constraint(equalTo: accessoryView.trailingAnchor, constant: -16),
      saveButton.centerYAnchor.constraint(equalTo: accessoryView.centerYAnchor)
      ])
  }
  
  private func setupClearButton() {
    clearButton = UIButton(type: .custom)
    clearButton.setTitle("Clear", for: .normal)
    clearButton.setTitleColor(UIColor.red, for: .normal)
    clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
    clearButton.showsTouchWhenHighlighted = true
  }
  
  private func setupSaveButton() {
    saveButton = UIButton(type: .custom)
    saveButton.setTitle("Save", for: .normal)
    saveButton.setTitleColor(UIColor.darkGreen, for: .normal)
    saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    saveButton.showsTouchWhenHighlighted = true
  }
  
  private func setupDeleteAllButton() {
    deleteAllButton = UIButton(type: .custom)
    deleteAllButton.setTitle("Delete all", for: .normal)
    deleteAllButton.setTitleColor(UIColor.red, for: .normal)
    deleteAllButton.addTarget(self, action: #selector(deleteAllButtonTapped), for: .touchUpInside)
    deleteAllButton.showsTouchWhenHighlighted = true
  }
  
  @objc private func saveButtonTapped() {
    // Dismissing the keyboard will trigger "textFieldDidFinishEditing"
    dismissKeyboard()
  }
  
  @objc private func deleteAllButtonTapped() {
    clearButtonTapped()
    model.deleteAll() { self.showSavingErrorToUser() }
    tableView.reloadData()
    view.endEditing(true)
  }
  
  @objc private func clearButtonTapped() {
    if let textView = view.firstResponder as? UITextView {
      let cell = textView.superview?.superview as! TableViewCell
      cell.isSelected = false
      cell.setCheckmark(false)
      textView.text = ""
      tableView.updateUI()
    }
  }
}

// -------------------------------------------------------------------------
// MARK: - Keyboard layout
// Notify when keyboard appears or dissapears
// Change TableView layout accordingly
extension TodayViewController {
  
  private func registerForKeyboardNotifications() {
    let keyboardWillShowNotification = UIResponder.keyboardWillShowNotification
    let keyboardWillHideNotification = UIResponder.keyboardWillHideNotification
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: keyboardWillHideNotification, object: nil)
  }

  @objc private func keyboardWillShow(notification: NSNotification) {
    let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
    adjustLayoutForKeyboard(targetHeight: keyboardFrame.size.height)
  }
  
  @objc private func keyboardWillHide(notification: NSNotification){
    adjustLayoutForKeyboard(targetHeight: UIEdgeInsets.zero.bottom)
  }
  
  private func adjustLayoutForKeyboard(targetHeight: CGFloat) {
    tableView.contentInset.bottom = targetHeight
  }
}

// -------------------------------------------------------------------------
// MARK: - Keyboard dismissal
extension TodayViewController {
  private func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tap.delegate = self
    view.addGestureRecognizer(tap)
  }
  
  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }
}

// -------------------------------------------------------------------------
// MARK: - Gesture recognizer delegate
// TableView's Cells won't trigger UITapGestureRecognizer.
// No interference with keyboard dissmissal and edit textField.
extension TodayViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    if let view = touch.view {
      for cell in tableView.visibleCells {
        if view.isDescendant(of: cell) {
          return false
        }
      }
    }
    return true
  }
}

// -------------------------------------------------------------------------
// MARK: - Table view delegate
extension TodayViewController: UITableViewDelegate {
  // Process data when row is selected and checked
  // and textView is not empty.
  // If goal is selected and become checked then all tasks will be.
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell
      else { return }
    trimming(textView: cell.textView)
    if cell.textView.text != "" {
      view.endEditing(true)
    }
    let isGoalCell = indexPath.section == 0
    let hasTitle = !cell.isPlaceHolderSet() && cell.textView.text != ""
    switch (isGoalCell, hasTitle) {
    case (true, true):
      model.goal(isSelected: true) { self.showSavingErrorToUser() }
    case (false, true):
      model.task(isSelected: true, index: indexPath.row) { self.showSavingErrorToUser() }
      triggerTaskAnimation = true
    default:
      cell.isSelected = false
      cell.setCheckmark(false)
      return
    }
    if model.isGoalCompleted {
      triggerGoalAnimation = true
    }
    tableView.reloadData()
  }
  
  // Process data when row is deselected and unchecked.
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell
      else { return }
    trimming(textView: cell.textView)
    if cell.textView.text != "" {
      view.endEditing(true)
    }
    switch indexPath.section {
    case 0:
      model.goal(isSelected: false, errorHandler: {self.showSavingErrorToUser()})
    default:
      model.task(isSelected: false, index: indexPath.row, errorHandler: {self.showSavingErrorToUser()})
      taskUnchecked = true
      triggerTaskAnimation = true
    }
    tableView.reloadData()
  }
  
  // Setup custom header for each section
  // Animate the headers if needed
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 {
      goalHeaderLabel = UILabel()
    } else {
      taskHeaderLabel = UILabel()
    }
    
    let view = UIView()
    
    let label: UILabel = section == 0 ? goalHeaderLabel : taskHeaderLabel
    
    view.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
    
    var title: String?
    
    if section == 0 {
      label.font = label.font.withSize(20)
      title = model.isGoalCompleted ? Constant.goalCompleted : Constant.goalUncompleted
      label.textColor = model.isGoalCompleted ? UIColor.red : UIColor.black
    }
    if section == 1 {
      label.font = label.font.withSize(15)
      let uncompletedTasksCount = model.uncompletedTasksCount
      if model.goalTitle == nil {
        title = Constant.taskNeedGoal
        label.textColor = UIColor.red
      } else {
        title = model.areAllTasksCompleted ? Constant.allTasksCompleted : "\(uncompletedTasksCount)" + Constant.notAllTasksUncompleted
      }
    }
    
    label.text = title
    
    if triggerGoalAnimation && section == 0 { goalCompletionAnimation() }
    if triggerTaskAnimation && section == 1 { taskAnimation(isUncheckedTask: taskUnchecked) }
    
    return view
  }
  
  private func taskAnimation(isUncheckedTask: Bool) {
    let temporaryMessage = taskUnchecked ? Constant.taskFailed : Constant.taskCompleted
    let color = taskUnchecked ? UIColor.red : UIColor.darkGreen
    
    let text = self.taskHeaderLabel.text
    self.taskHeaderLabel.alpha = 0
    self.taskHeaderLabel.textColor = color
    self.taskHeaderLabel.text = temporaryMessage
    
    let animation = { self.taskHeaderLabel.alpha = 0 }
    
    let completion = {
      (completed: Bool) in
      if completed {
        self.taskHeaderLabel.textColor = UIColor.black
        self.taskHeaderLabel.text = text
        UIView.animate(withDuration: 0.5) { self.taskHeaderLabel.alpha = 1 }
      }
    }
    
    let mainCompletion = {
      (completed: Bool) in
      if completed {
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: animation, completion: completion)
      }
    }
    
    UIView.setAnimationsEnabled(true)
    UIView.animate(withDuration: 0.5, animations: { self.taskHeaderLabel.alpha = 1 }, completion: mainCompletion)
    
    triggerTaskAnimation = false
    taskUnchecked = false
  }
  
  private func goalCompletionAnimation() {
    UIView.setAnimationsEnabled(true)
    
    UIView.animate(withDuration: 0.6) { () -> Void in
      self.goalHeaderLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
      self.goalHeaderLabel.transform = CGAffineTransform(scaleX: 2, y: 2)
    }

    UIView.animate(withDuration: 0.6, delay: 0.3, options: UIView.AnimationOptions.curveEaseIn, animations: {
      () -> Void in
      self.goalHeaderLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
//      self.goalHeaderLabel.transform = CGAffineTransform.identity
    }, completion: nil)
    
    triggerGoalAnimation = false
  }
  
  private func trimming(textView: UITextView) {
    textView.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    tableView.updateUI()
  }
}

// -------------------------------------------------------------------------
// MARK: - Table view data source
extension TodayViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 1 : 3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      if let cell = tableView.dequeueReusableCell(withIdentifier: Constant.goalCellId) as? GoalTableViewCell {
        setupGoalCell(cell: cell, indexPath: indexPath)
        return cell
      }
    case 1:
      if let cell = tableView.dequeueReusableCell(withIdentifier: Constant.taskCellId) as? TaskTableViewCell {
        setupTaskCell(cell: cell, indexPath: indexPath)
        return cell
      }
    default: break
    }
    return UITableViewCell()
  }
  
  // Implemented without returning "" or nil gives a dynamic height to header sections
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "default"
  }
  
  /// Setup goal cell's text field
  ///
  /// - Parameters:
  ///   - cell: task cell
  ///   - indexPath: tableView indexPath
  private func setupGoalCell(cell: GoalTableViewCell, indexPath: IndexPath) {
    if let title = model.goalTitle {
      cell.textView.text = title
      cell.textView.textColor = UIColor.black
    } else {
      cell.setPlaceHolder()
    }
    cell.tag = -1
    cell.textView.inputAccessoryView = accessoryView
    cell.delegate = self
    setCellSelectionColor(cell: cell)
    selectionRow(isSelected: model.isGoalCompleted, cell: cell, indexPath: indexPath)
  }
  
  /// Setup task cell's label and text field
  ///
  /// - Parameters:
  ///   - cell: task cell
  ///   - indexPath: indexPath of the cell in TableView
  private func setupTaskCell(cell: TaskTableViewCell, indexPath: IndexPath) {
    let row = indexPath.row
    if let title = model.taskTitle(order: row) {
      cell.textView.text = title
      cell.textView.textColor = UIColor.black
    } else {
      cell.setPlaceHolder()
    }
    cell.numberLabel.text = "\(row + 1)"
    cell.tag = row
    cell.textView.inputAccessoryView = accessoryView
    cell.delegate = self
    setCellSelectionColor(cell: cell)
    let isSelected = model.isCompletedTask(order: row)
    selectionRow(isSelected: isSelected, cell: cell, indexPath: indexPath)
  }
  
  /// Select or deselect a row in tableView.
  /// check mark or uncheck mark a cell
  ///
  /// - Parameters:
  ///   - isSelected: cell should be selected
  ///   - cell: cell to select or deselect
  ///   - indexPath: indexPath of the cell in TableView
  private func selectionRow(isSelected: Bool, cell: TableViewCell, indexPath: IndexPath) {
    if isSelected {
      tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
      cell.setCheckmark(true)
    } else {
      tableView.deselectRow(at: indexPath, animated: true)
      cell.setCheckmark(false)
    }
  }
  
  /// Set the selection color that will apply
  ///
  /// - Parameters:
  ///   - cell: cell to be colored
  private func setCellSelectionColor(cell: UITableViewCell) {
    cell.selectedBackgroundView = UIView()
    cell.selectedBackgroundView?.backgroundColor = Constant.selectionBackgroundColor
  }
}

// -------------------------------------------------------------------------
// MARK: - Tableview cell delegate
extension TodayViewController: TableViewCellDelegate {
  // Resize the cell dynamically with an animation
  func dynamicSize(cell: TableViewCell) {
    tableView.updateUI()
    // Keep the bottom of the cell visible on the screen
    if let indexPath = tableView.indexPath(for: cell) {
      tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
  }
  
  func textViewDidFinishEditing(cell: TableViewCell, tag index: Int) {
    tableView.updateUI()
    // No need to process data if no changes
    guard cell.formerText != cell.textView.text else { return }
    var type: Type!
    // Check if input comes from a GoalTableViewCell or TaskTableViewCell
    // Get NSManagedObject accordingly
    if let _ = cell as? GoalTableViewCell {
      type = .goal
    }
    if let _ = cell as? TaskTableViewCell {
      type = .task
    }
    model.processData(title: cell.textView.text, order: index, type: type) {
      self.showSavingErrorToUser()
    }
    tableView.reloadData()
  }
}
