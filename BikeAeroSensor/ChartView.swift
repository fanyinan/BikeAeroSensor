//
//  ChartView2.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/19.
//

import UIKit
import Algorithms

class ChartData {
    var values: [Double?]
    var color: UIColor = .random
    
    init(count: Int) {
        values = [Double?](repeating: nil, count: count)
    }
}

protocol ChartViewDataSource: NSObjectProtocol {
    func chartData(_ chartView: ChartView) -> [String: Double]
    func lineColor(_ key: String) -> UIColor
}

class ChartView: UIView {

    private let chart = Chart()
    private var datas: [String: ChartData] = [:]
    let xAxisCount = 30
    var maxValueCount: Int { xAxisCount + 1 }

    weak var dataSource: ChartViewDataSource?
    
    var isPause: Bool = true {
        didSet {
            displayLink.isPaused = isPause
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        chart.xLabels = (0...xAxisCount).striding(by: 2).map({ Double($0) })
        chart.yLabels = (-20...180).striding(by: 20).map({ Double($0) })
        chart.xLabelsFormatter = { _, _ in "" }
        chart.labelColor = .white
        chart.gridColor = #colorLiteral(red: 0.9878740907, green: 1, blue: 1, alpha: 0.1)
        chart.axesColor = #colorLiteral(red: 0.9878740907, green: 1, blue: 1, alpha: 0.1)
        addSubview(chart)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chart.frame = bounds
    }
    
    lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: RunLoop.main, forMode: .default)
        displayLink.isPaused = true
        displayLink.preferredFramesPerSecond = 30
        return displayLink
    }()
    
    @objc func update() {
        
//        for value in datas.values {
//            guard value.values.count > maxValueCount else { continue }
//            value.values.removeFirst()
//        }
        
        for data in datas.values {
            
            for i in 0..<data.values.count - 1 {
                data.values[i] = data.values[i + 1]
            }
            data.values[data.values.count - 1] = nil
        }
        
        if let newData = self.dataSource?.chartData(self) {
            for (key, value) in newData {
                let data: ChartData
                if let _data = datas[key] {
                    data = _data
                } else {
                    data = ChartData(count: maxValueCount)
                    datas[key] = data
                }
                data.values[maxValueCount - 1] = value
                data.color = self.dataSource!.lineColor(key)
            }
        }
                
        chart.removeAllSeries()

        for data in datas.values {
            
            var i = 0
            var valueList: [(Int, Double)]?
            
            while i < data.values.count {
                if let value = data.values[i] {
                    
                    if valueList == nil {
                        valueList = []
                    }
                    
                    valueList!.append((i, value))
                    
                } else {
                    
                    if let _valueList = valueList {
                        let series = ChartSeries(data: _valueList)
                        series.color = data.color
                        chart.add(series)
                        valueList = nil
                    }
                }
                
                i += 1
            }
            
            if let _valueList = valueList {
                let series = ChartSeries(data: _valueList)
                series.color = data.color
                chart.add(series)
                valueList = nil
            }
        }
    }
}
