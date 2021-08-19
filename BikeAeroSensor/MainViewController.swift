//
//  MainViewController.swift
//  BikeAeroSensor
//
//  Created by yinan17 on 2021/8/18.
//

import UIKit

struct ProbeData {
    let currentDataIndex: Int
    let wiFiSignalStrength: Int
    let currentDataFrequency: Int
    let batteryVoltage: Double
    let windSpeed: Double
    let windPitching: Double
    let windYaw: Double
    let sensorPitch: Double
    let sensorRoll: Double
    let sensoryaw: Double
    let bmpTemperature: Double
    let bmpPressure: Double
    let visualData: [String: Double]
}

class VisualInfo {
    let label: String
    let color: UIColor
    var values: [Double] = []
    var needShow = false {
        didSet {
            if !needShow {
                values.removeAll()
            }
        }
    }
    
    init(label: String, color: UIColor) {
        self.label = label
        self.color = color
    }
    
    func appendValue(_ value: Double) {
        guard needShow else { return }
        values.append(value)
        if values.count > 60 {
            values.removeFirst()
        }
    }
}

class MainViewController: UIViewController {

    private let chartView = ChartView()
    private let chartContainerView = UIView()
    private let udp = UDP()
    private var legendButtons: [UIButton] = []
    
    var currentData: ProbeData?
    
    private var visualDatas: [VisualInfo] = [
        VisualInfo(label: "differentialPressure0", color: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)),
        VisualInfo(label: "differentialPressure1", color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)),
        VisualInfo(label: "differentialPressure2", color: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)),
        VisualInfo(label: "differentialPressure3", color: #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)),
        VisualInfo(label: "differentialPressure4", color: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)),
        VisualInfo(label: "averageDPTemperature", color: #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)),
        VisualInfo(label: "icmAccX", color: #colorLiteral(red: 0.5810584426, green: 0.1285524964, blue: 0.5745313764, alpha: 1)),
        VisualInfo(label: "icmAccY", color: #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)),
        VisualInfo(label: "icmGyrZ", color: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)),
        VisualInfo(label: "icmGyrX", color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)),
        VisualInfo(label: "icmGyrY", color: #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)),
        VisualInfo(label: "icmGyrZ", color: #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1)),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(chartContainerView)
        chartContainerView.backgroundColor = #colorLiteral(red: 0.03921568627, green: 0.4039215686, blue: 0.7019607843, alpha: 1)
        chartContainerView.addSubview(chartView)
        udp.delegate = self
        try! udp.listen(port: 1133)
        
        setupLegend()
        chartView.updateBlock = { [weak self] () -> [String: Double] in
            guard let self = self else { return [:] }
//            let data = self.currentData?.visualData ?? [:]
//            self.currentData = nil
            let data: [String: Double] = ["differentialPressure0": Double.random(in: 30..<40)]
            return data
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        chartContainerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 400)
        chartView.frame = CGRect(x: 12, y: view.safeAreaInsets.top + 12, width: view.frame.width - 24, height: chartContainerView.frame.height - view.safeAreaInsets.top - 12)
        
        let colCount = 3
        let space: CGFloat = 8
        let width: CGFloat = (view.width - space * CGFloat(colCount + 1)) / CGFloat(colCount)
        let height: CGFloat = 30
        
        for (i, button) in legendButtons.enumerated() {
            
            let row = i / colCount
            let col = i % colCount
            
            button.frame = CGRect(x: space + CGFloat(col) * (width + space), y: chartContainerView.maxY + space + CGFloat(row) * (height + space), width: width, height: height)
            
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chartView.isPause = false
    }
    
    private func setupLegend() {
        
        legendButtons = visualDatas.map({ data -> UIButton in
            let button = UIButton()
            button.setTitle(data.label, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(.black, for: .selected)
            button.isSelected = true
            button.backgroundColor = data.color
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.addTarget(self, action: #selector(onClickLegend(_:)), for: .touchUpInside)
            view.addSubview(button)
            return button
        })
    }
    
    @objc private func onClickLegend(_ button: UIButton) {
        
        let index = legendButtons.firstIndex(of: button)!
        button.isSelected = !button.isSelected
        visualDatas[index].needShow = !visualDatas[index].needShow
    }
}


extension MainViewController: UDPDelegate {

    func udp(_ udp: UDP, didReceive data: Data, fromHost host: String, port: UInt16) {
        let str = String(data: data, encoding: .utf8)!
        let values = str.split(separator: ",").map({ String($0) })
        
        var visualData: [String: Double] = [:]
        let currentDataIndex = Int(Double(values[0])!)
        let wiFiSignalStrength = Int(Double(values[1])!)
        let currentDataFrequency = Int(Double(values[2])!)
        let batteryVoltage = Double(values[3])!
//        appendValue(Double(values[4])!, for: "differentialPressure0")
//        appendValue(Double(values[5])!, for: "differentialPressure1")
//        appendValue(Double(values[6])!, for: "differentialPressure2")
//        appendValue(Double(values[7])!, for: "differentialPressure3")
//        appendValue(Double(values[8])!, for: "differentialPressure4")
//        appendValue(Double(values[9])!, for: "averageDPTemperature")
        visualData["differentialPressure0"] = Double(values[4])!
        visualData["differentialPressure1"] = Double(values[5])!
        visualData["differentialPressure2"] = Double(values[6])!
        visualData["differentialPressure3"] = Double(values[7])!
        visualData["differentialPressure4"] = Double(values[8])!
        visualData["averageDPTemperature"] = Double(values[9])!

        let bmpTemperature = Double(values[10])!
        let bmpPressure = Double(values[11])!
        let pitchAngle = Double(values[12])!
        let rollAngle = Double(values[13])!
        let yawAngle = Double(values[14])!
//        appendValue(Double(values[15])!, for: "icmAccX")
//        appendValue(Double(values[16])!, for: "icmAccY")
//        appendValue(Double(values[17])!, for: "icmAccZ")
//        appendValue(Double(values[18])!, for: "icmGyrX")
//        appendValue(Double(values[19])!, for: "icmGyrY")
//        appendValue(Double(values[20])!, for: "icmGyrZ")
        
        visualData["icmAccX"] = Double(values[15])!
        visualData["icmAccY"] = Double(values[16])!
        visualData["icmAccZ"] = Double(values[17])!
        visualData["icmGyrX"] = Double(values[18])!
        visualData["icmGyrY"] = Double(values[19])!
        visualData["icmGyrZ"] = Double(values[20])!
        
        let probeData = ProbeData(currentDataIndex: currentDataIndex, wiFiSignalStrength: wiFiSignalStrength, currentDataFrequency: currentDataFrequency, batteryVoltage: batteryVoltage, windSpeed: 0, windPitching: 0, windYaw: 0, sensorPitch: pitchAngle, sensorRoll: rollAngle, sensoryaw: yawAngle, bmpTemperature: bmpTemperature, bmpPressure: bmpPressure, visualData: visualData)
        self.currentData = probeData
//        let chartDatas = visualDatas.filter({ !$0.values.isEmpty }).map({ ChartData(values: $0.values, color: $0.color) })
        print("receive", probeData.currentDataIndex)
    }
    
    private func appendValue(_ value: Double, for key: String) {
        visualDatas.filter({ $0.label == key }).first?.appendValue(value)
    }
}
