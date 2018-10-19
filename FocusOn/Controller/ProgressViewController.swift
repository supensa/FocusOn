//
//  ProgressViewController.swift
//  FocusOn
//
//  Created by Spencer Forrest on 23/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit
import Charts

class ProgressViewController: UIViewController, ViewControllerProtocol {
  
  @IBOutlet weak var barChartView: HorizontalBarChartView!
  @IBOutlet weak var segmentControl: UISegmentedControl!
  
  var dataController: DataController!
  private var progressDataManager: ProgressDataManager!
  
  var labels = [String]()
  
  var completedGoals = [Double]()
  var completedTasks = [Double]()
  
  var goalDataSet: BarChartDataSet!
  var taskDataSet: BarChartDataSet!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    barChartView.noDataText = "You need to provide data for this chart."
    progressDataManager = ProgressDataManager.init(dataController)
//    Test.shared.saveTestData(dataController: dataController)
    
    //legend
    let legend = barChartView.legend
    legend.enabled = true
    legend.horizontalAlignment = .center
    legend.verticalAlignment = .top
    legend.yOffset = 10
    legend.xOffset = 0
    legend.orientation = .horizontal
    legend.drawInside = true
    
    let xaxis = barChartView.xAxis
    xaxis.drawGridLinesEnabled = false
    xaxis.labelPosition = .bottom
    xaxis.centerAxisLabelsEnabled = true
    xaxis.valueFormatter = IndexAxisValueFormatter(values: self.labels)
    xaxis.setLabelCount(self.labels.count, force: false)
    
    barChartView.drawValueAboveBarEnabled = true
    
    let rightAxis = barChartView.rightAxis
    rightAxis.enabled = false
    
    let leftAxis = barChartView.leftAxis
    leftAxis.axisMinimum = 0
    leftAxis.axisMaximum = 100
    leftAxis.drawGridLinesEnabled = true
    
    // Background colors
    barChartView.backgroundColor = Constant.selectionBackgroundColor
    barChartView.tintColor = .white
    barChartView.drawGridBackgroundEnabled = true
    barChartView.gridBackgroundColor = UIColor.white
    // Disabling user interaction features
    barChartView.scaleYEnabled = false
    barChartView.scaleXEnabled = false
    barChartView.pinchZoomEnabled = false
    barChartView.doubleTapToZoomEnabled = false
    barChartView.highlightPerTapEnabled = true
    
    barChartView.minOffset = 30
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.loadDataInGraph()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.loadDataInGraph(isEmpty: true)
  }
  
  @IBAction func periodChanged() {
    self.loadDataInGraph()
  }
  
  private func loadDataInGraph(isEmpty: Bool = false) {
    let index = isEmpty ? -1 : self.segmentControl.selectedSegmentIndex
    switch index {
    case Constant.monthlySegmentIndex:
      print("This Year")
      let results = progressDataManager.completedFocuses(isMonthly: true)
      let labels = progressDataManager.labels
      self.updateCompletedFocuses(results: results, labels: labels)
    case Constant.weeklySegmentIndex:
      print("This Month")
      let results = progressDataManager.completedFocuses(isMonthly: false)
      let labels = progressDataManager.labels
      self.updateCompletedFocuses(results: results, labels: labels)
    default:
      print("This Reset")
      let results = [String : [Double]]()
      let labels = [String]()
      self.updateCompletedFocuses(results: results, labels: labels)
    }
    
    let xaxis = barChartView.xAxis
    xaxis.valueFormatter = IndexAxisValueFormatter(values: self.labels)
    xaxis.setLabelCount(self.labels.count, force: false)
    
    setChart()
  }
  
  private func updateCompletedFocuses(results: [String : [Double]], labels: [String]) {
    self.labels = labels
    self.completedGoals = [Double]()
    self.completedTasks = [Double]()
    for label in labels {
      if let goalResult = results[label]?[0] {
        self.completedGoals.append(goalResult)
      }
      if let taskResult = results[label]?[1] {
        self.completedTasks.append(taskResult)
      }
    }
  }
  
  private func setChart() {
    if completedGoals.isEmpty && completedTasks.isEmpty {
      barChartView.data = nil
      barChartView.notifyDataSetChanged()
      return
    }
    updateDataSet()
    updateBarChartData()
    barChartView.notifyDataSetChanged()
  }
  
  private func updateBarChartData() {
    let chartData = BarChartData(dataSets: [taskDataSet, goalDataSet])
    chartData.setValueFormatter(Formatter())
    let barWidth = 0.4
    let barSpace = 0.0
    let groupSpace = 0.2
    chartData.barWidth = barWidth
    // (0.4 + 0.00) * 2 + 0.2 = 1.00 -> interval per "group"
    // (barWidth + barSpace) * (no.of.bars) + groupSpace = 1.00 -> interval per "group"
    let groupCount = self.labels.count
    let startYear = 0
    
    barChartView.xAxis.axisMinimum = Double(startYear)
    barChartView.xAxis.axisMaximum = Double(startYear) + Double(groupCount)
    chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
    barChartView.data = chartData
  }
  
  private func updateDataSet() {
    var goalDataEntries: [BarChartDataEntry] = []
    var taskDataEntries: [BarChartDataEntry] = []
    
    for i in 0..<self.labels.count {
      
      let dataEntry = BarChartDataEntry(x: Double(i) , y: self.completedGoals[i])
      goalDataEntries.append(dataEntry)
      
      let dataEntry1 = BarChartDataEntry(x: Double(i) , y: self.completedTasks[i])
      taskDataEntries.append(dataEntry1)
    }
    
    goalDataSet = BarChartDataSet(values: goalDataEntries, label: "% goals completed")
    taskDataSet = BarChartDataSet(values: taskDataEntries, label: "% tasks completed")
    
    goalDataSet.colors = [UIColor.black]
    goalDataSet.highlightColor = .clear
    goalDataSet.drawValuesEnabled = true
    
    taskDataSet.colors = [UIColor.lightGray]
    taskDataSet.highlightColor = .clear
    taskDataSet.drawValuesEnabled = true
  }
}

/// Needed class conforming to IValueFormatter protocol.
/// Used to round value and show it on graph if not equal to 0.0
class Formatter: IValueFormatter {
  func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
    return value == 0.0 ? "" : String.init(format: "%.0f", value.rounded())
  }
}
