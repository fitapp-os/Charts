//
//  FitappPaceDemoViewController.swift
//  ChartsDemo-iOS-Swift
//
//  Created by Eman Basic on 02.01.24.
//  Copyright © 2024 dcg. All rights reserved.
//

import UIKit
import DGCharts

final class FitappPaceDemoViewController: UIViewController {
    @IBOutlet private var barChartView: HorizontalBarChartView!
    
    private let paceValues: [Double] = [38, 22, 12, 22, 60, 80, 115, 524]
    private let distanceValues: [Double] = [8.5, 8, 7, 5, 4, 3, 2, 1]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    
    private func initialize() {
        edgesForExtendedLayout = []
        title = "Fitapp Pace Demo"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChartUI()
        setupChart()
    }
    
    private func setupChartUI() {
        barChartView.extraBottomOffset = 80
        barChartView.backgroundColor = .white
        barChartView.drawGridBackgroundEnabled = false
        barChartView.gridBackgroundColor = .white
        barChartView.chartDescription.text = ""
        barChartView.drawBordersEnabled = false
        barChartView.dragEnabled = false
        barChartView.scaleXEnabled = false
        barChartView.scaleYEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.drawBarShadowEnabled = false
        barChartView.legend.enabled = false
        barChartView.drawValueAboveBarEnabled = false
        barChartView.roundedCorners = .allCorners
        barChartView.cornerRadius = .custom(value: 7)

        // X axis (Distance)
        let xAxis = barChartView.xAxis
        xAxis.axisMaxLabels = Int.max
        xAxis.axisMinLabels = 2
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.labelPosition = XAxis.LabelPosition.bottom
        xAxis.gridColor = .white
        xAxis.labelTextColor = .gray
        xAxis.labelFont = .systemFont(ofSize: 16)
        xAxis.granularityEnabled = true
        xAxis.granularity = 0.5
        xAxis.centerAxisLabelsEnabled = true
        xAxis.avoidFirstLastClippingEnabled = true

        // Y axis (Pace)
        let leftAxis = barChartView.leftAxis
        leftAxis.axisMaxLabels = Int.max
        leftAxis.axisMinLabels = 2
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawZeroLineEnabled = false
        leftAxis.drawLabelsEnabled = false
        leftAxis.labelPosition = YAxis.LabelPosition.insideChart
        if !paceValues.isEmpty {
            let maxPace = paceValues.max()!
            leftAxis.axisMaximum = maxPace
            leftAxis.axisMinimum = 0
        }

        // hide right Y axis
        let rightAxis = barChartView.rightAxis
        rightAxis.axisMaxLabels = Int.max
        rightAxis.axisMinLabels = 2
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawLabelsEnabled = false
    }
    
    private func setupChart() {
        // distance data
        let distanceStrings = distanceValues.map { String(format: "%0.1f", locale: .current, $0) }

        // dace data set
        let paceDataEntries = dataEntriesForValues(paceValues)
        let paceDataSet = BarChartDataSet(entries: paceDataEntries, label: "")
        paceDataSet.valueTextColor = UIColor.white
        paceDataSet.valueFont = .systemFont(ofSize: 16)
        paceDataSet.highlightEnabled = false
        paceDataSet.drawValuesEnabled = true
        
        let paceFormatter = DateFormatter()
        paceFormatter.dateFormat = "mm:ss"
        paceDataSet.valueFormatter = paceFormatter

        // chart data
        let barChartData = BarChartData(dataSets: [paceDataSet])
        barChartData.barWidth = 0.75

        barChartView.xAxis.setLabelCount(distanceStrings.count + 1, force: true)
        barChartView.xAxis.valueFormatter = DefaultAxisValueFormatter { value, _ in
            let normalizedValue = Int(value + 0.5)
            guard normalizedValue >= 0, normalizedValue < distanceStrings.count else {
                return ""
            }

            let distance = distanceStrings[normalizedValue]
            return "\(String(repeatElement(" ", count: max(0, 5 - distance.count))))\(distance)   "
        }

        barChartView.data = barChartData

        defineColorsForSet(paceDataSet)
    }

    private func defineColorsForSet(_ dataSet: BarChartDataSet) {
        guard !paceValues.isEmpty else { return }

        dataSet.resetColors()

        if paceValues.count == 1 {
            dataSet.addColor(.purple)
            return
        }

        dataSet.calcMinMax()

        for index in 0 ..< paceValues.count {
            switch paceValues[index] {
            case dataSet.yMax:
                dataSet.addColor(.red)
            case dataSet.yMin:
                dataSet.addColor(.green)
            default:
                dataSet.addColor(.purple)
            }
        }
    }

    private func dataEntriesForValues(_ values: [Double]) -> [BarChartDataEntry] {
        var dataEntries: [BarChartDataEntry] = []
        for i in 0 ..< values.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        return dataEntries
    }
}

extension DateFormatter: ValueFormatter {
    public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        guard let date = dateFromSeconds(seconds: value) else {
            return ""
        }
        
        return string(from: date)
    }

    private func dateFromSeconds(seconds: Double) -> Date? {
        var remainingSeconds = Int(seconds)
        let hours: Int = remainingSeconds / 3600

        remainingSeconds -= hours * 3600
        let minutes: Int = remainingSeconds / 60

        remainingSeconds -= minutes * 60

        let calendar = NSCalendar.current

        var dateComponents = DateComponents()
        dateComponents.hour = hours
        dateComponents.minute = minutes
        dateComponents.second = remainingSeconds
        
        return calendar.date(from: dateComponents)
    }
}
