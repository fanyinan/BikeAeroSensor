//
//  ChartView.swift
//  BikeAeroSensor
//
//  Created by yinan17 on 2021/8/18.
//

import UIKit
import Charts

struct ChartData {
    let values: [Double]
    let color: UIColor
}

class ChartView: UIView {
    
    var datas: [ChartData] = [ChartData(values: [], color: .white), ChartData(values: [], color: .red)]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        addSubview(lineChartView)
        // Do any additional setup after loading the view.
//        chartView.delegate = self

        lineChartView.chartDescription.enabled = false
        lineChartView.dragEnabled = true
        lineChartView.setScaleEnabled(true)
        lineChartView.pinchZoomEnabled = true

        // x-axis limit line
//        let llXAxis = ChartLimitLine(limit: 10, label: "Index 10")
//        llXAxis.lineWidth = 4
//        llXAxis.lineDashLengths = [10, 10, 0]
//        llXAxis.labelPosition = .rightBottom
//        llXAxis.valueFont = .systemFont(ofSize: 10)

//        chartView.xAxis.gridLineDashLengths = [10, 10]
//        chartView.xAxis.gridLineDashPhase = 0

//        let ll1 = ChartLimitLine(limit: 150, label: "Upper Limit")
//        ll1.lineWidth = 4
//        ll1.lineDashLengths = [5, 5]
//        ll1.labelPosition = .rightTop
//        ll1.valueFont = .systemFont(ofSize: 10)
//
//        let ll2 = ChartLimitLine(limit: -30, label: "Lower Limit")
//        ll2.lineWidth = 4
//        ll2.lineDashLengths = [5,5]
//        ll2.labelPosition = .rightBottom
//        ll2.valueFont = .systemFont(ofSize: 10)

        let lineColor: UIColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.3)
        let leftAxis = lineChartView.leftAxis
        leftAxis.removeAllLimitLines()
//        leftAxis.addLimitLine(ll1)
//        leftAxis.addLimitLine(ll2)
        leftAxis.axisMaximum = 200
        leftAxis.axisMinimum = -50
        leftAxis.labelTextColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        leftAxis.gridColor = lineColor
//        leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.drawLimitLinesBehindDataEnabled = true
        leftAxis.axisLineColor = lineColor

        lineChartView.rightAxis.enabled = false
        lineChartView.xAxis.gridColor = lineColor
        lineChartView.xAxis.labelTextColor = .clear
        lineChartView.xAxis.axisLineColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineChartView.frame = bounds
    }
    
    var lineChartView = LineChartView()

    lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: RunLoop.main, forMode: .default)
        displayLink.isPaused = true
        if #available(iOS 10.0, *) {
            displayLink.preferredFramesPerSecond = 30
        } else {
            // Fallback on earlier versions
        }
        return displayLink
    }()

    private func setup(_ dataSet: LineChartDataSet) {
        if dataSet.isDrawLineWithGradientEnabled {
            dataSet.lineDashLengths = nil
            dataSet.highlightLineDashLengths = nil
            dataSet.setColors(.black, .red, .white)
            dataSet.setCircleColor(.black)
            dataSet.gradientPositions = [0, 40, 100]
            dataSet.lineWidth = 1
            dataSet.circleRadius = 3
            dataSet.drawCircleHoleEnabled = false
            dataSet.valueFont = .systemFont(ofSize: 9)
            dataSet.formLineDashLengths = nil
            dataSet.formLineWidth = 1
            dataSet.formSize = 15
        } else {
//            dataSet.lineDashLengths = [5, 2.5]
//            dataSet.highlightLineDashLengths = [5, 2.5]
            dataSet.setColor(.white)
            dataSet.setCircleColor(.black)
            dataSet.gradientPositions = nil
            dataSet.lineWidth = 2
            dataSet.circleRadius = 3
            dataSet.drawCircleHoleEnabled = false
            dataSet.valueFont = .systemFont(ofSize: 9)
            dataSet.formLineDashLengths = [5, 2.5]
            dataSet.formLineWidth = 1
            dataSet.formSize = 15
        }
    }

    var isPause: Bool = true {
        didSet {
            displayLink.isPaused = isPause
        }
    }
    
    private var testValues: [[Double]] = [[], []]
    
    @objc func update() {
        
        var sets: [LineChartDataSet] = []
        for (i, data) in datas.enumerated() {
            
            if i == 0 {
                testValues[i].append(Double.random(in: 50..<55))
            } else if i == 1 {
                testValues[i].append(Double.random(in: 30..<40))
            }

            if testValues[i].count > 60 {
                testValues[i].removeFirst()
            }
            
            let values = (0..<testValues[i].count).map { j in
                return ChartDataEntry(x: Double(j), y: testValues[i][j])
            }

            let set = LineChartDataSet(entries: values, label: "udp")
            set.drawIconsEnabled = false
            set.drawValuesEnabled = false
            set.drawCirclesEnabled = false
    //        set1.line
            setup(set)
            
            set.colors = [data.color]
            sets.append(set)
        }
        

//        let value = ChartDataEntry(x: Double(3), y: 3)
//        set1.addEntryOrdered(value)
//        let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor,
//                              ChartColorTemplates.colorFromString("#ffff0000").cgColor]
//        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
//
//        set1.fillAlpha = 1
//        set1.fill = LinearGradientFill(gradient: gradient, angle: 90)
//        set1.drawFilledEnabled = true

        let data = LineChartData(dataSets: sets)

        lineChartView.data = data
        lineChartView.legend.setCustom(entries: [])
    }
}
