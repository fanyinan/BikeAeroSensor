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
    var displayData: [DynamicData]
}

class VisualInfo {
    let label: String
    let color: UIColor
    var values: [Double] = []
    var needShow: Bool
    
    init(label: String, color: UIColor, needShow: Bool = true) {
        self.label = label
        self.color = color
        self.needShow = needShow
    }
}

class MainViewController: UIViewController {

    private let chartView = ChartView()
    private var legendButtons: [UIButton] = []
    private let topBarView = UIView()
    private let recordButton = UIButton()
    private let fileButton = UIButton()
    private let settingButton = UIButton()
    private let tareButton = UIButton()
    private let displayDataView = UIView()
    private var displayDataLabels: [UILabel] = []
    private let bottomView = UIView()
    private let slider = Slider()
    private let sendButtonContainerView = UIView()
    private var sendButtons: [UIButton] = []
    private let legendView = GridView(cellType: LegendCell.self)
    private let menuView = MenuView.loadFromNib()
    private let dynamicDataView = GridView(cellType: DynamicDataCell.self)
    
    private var currentData: ProbeData?
    
    private var isBegin = false
    private var toleranceFrameCount = 5
    private var currentDelayCount = 0
    private var backupData: [String: Double]?
    
    private var tarePreData: [String: [Double]]?
    private let tarePreDataCount = 10
    private var tareData: [String: Double]?
    
    private let sendDatas: [String] = ["R", "A", "M"]
    
    #if DEBUG
    private var delayFrame = 0
    private var delayFrameList = [Int](repeating: 0, count: 20)
    #endif

    private var visualDatas: [VisualInfo] = [
        VisualInfo(label: "currentDataFrequency", color: #colorLiteral(red: 0.2671898305, green: 1, blue: 0.5297580957, alpha: 1)),
        VisualInfo(label: "dpTemp", color: #colorLiteral(red: 0.6042316556, green: 0.09232855588, blue: 0.2760148644, alpha: 1)),
        VisualInfo(label: "ATM", color: #colorLiteral(red: 0.9821859002, green: 0.489916265, blue: 0.2320583761, alpha: 1)),
        VisualInfo(label: "pitchAngle", color: #colorLiteral(red: 0.820196569, green: 0.85434407, blue: 0, alpha: 1)),
        VisualInfo(label: "rollAngle", color: #colorLiteral(red: 0.1820499003, green: 0.5240936279, blue: 0.9926010966, alpha: 1)),
        VisualInfo(label: "yawAngle", color: #colorLiteral(red: 0.8631967902, green: 0.1063003018, blue: 0.9723851085, alpha: 1)),
        VisualInfo(label: "differentialPressure0", color: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)),
        VisualInfo(label: "differentialPressure1", color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)),
        VisualInfo(label: "differentialPressure2", color: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)),
        VisualInfo(label: "differentialPressure3", color: #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)),
        VisualInfo(label: "differentialPressure4", color: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)),
        VisualInfo(label: "averageDPTemperature", color: #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)),
        VisualInfo(label: "icmAccX", color: #colorLiteral(red: 0.5810584426, green: 0.1285524964, blue: 0.5745313764, alpha: 1)),
        VisualInfo(label: "icmAccY", color: #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)),
        VisualInfo(label: "icmAccZ", color: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)),
        VisualInfo(label: "icmGyrX", color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)),
        VisualInfo(label: "icmGyrY", color: #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)),
        VisualInfo(label: "icmGyrZ", color: #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1)),
    ]

    private lazy var colorDict: [String: UIColor] = {
        return Dictionary(uniqueKeysWithValues: visualDatas.map{ ($0.label, $0.color) })
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .theme
        
//        view.addSubview(topBarView)
//        topBarView.addSubview(recordButton)
//        recordButton.setTitle("开始录制", for: .normal)
//        recordButton.setTitle("停止录制", for: .selected)
//        recordButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
//        recordButton.setTitleColor(.white, for: .normal)
//        recordButton.backgroundColor = #colorLiteral(red: 0.3471153975, green: 0.5619726777, blue: 0.6928223372, alpha: 1)
//        recordButton.addTarget(self, action: #selector(onRecord(_:)), for: .touchUpInside)
//        topBarView.addSubview(fileButton)
//        fileButton.setTitle("文件", for: .normal)
//        fileButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
//        fileButton.setTitleColor(.white, for: .normal)
//        fileButton.backgroundColor = #colorLiteral(red: 0.3471153975, green: 0.5619726777, blue: 0.6928223372, alpha: 1)
//        fileButton.addTarget(self, action: #selector(onFile(_:)), for: .touchUpInside)
//        topBarView.addSubview(settingButton)
//        settingButton.setTitle("设置", for: .normal)
//        settingButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
//        settingButton.setTitleColor(.white, for: .normal)
//        settingButton.backgroundColor = #colorLiteral(red: 0.3471153975, green: 0.5619726777, blue: 0.6928223372, alpha: 1)
//        settingButton.addTarget(self, action: #selector(onSetting(_:)), for: .touchUpInside)
//        topBarView.addSubview(tareButton)
//        tareButton.setTitle("Tare", for: .normal)
//        tareButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
//        tareButton.setTitleColor(.white, for: .normal)
//        tareButton.backgroundColor = #colorLiteral(red: 0.3471153975, green: 0.5619726777, blue: 0.6928223372, alpha: 1)
//        tareButton.addTarget(self, action: #selector(onTare(_:)), for: .touchUpInside)
//        view.addSubview(displayDataView)
        view.addSubview(chartView)
        chartView.dataSource = self
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        bottomView.addSubview(slider)
        
        bottomView.addSubview(sendButtonContainerView)
        sendButtonContainerView.isHidden = true
        
        sendButtons = sendDatas.map({ data -> UIButton in
            let button = UIButton()
            button.setTitle(data, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = #colorLiteral(red: 0.3406233788, green: 0.6707556844, blue: 1, alpha: 1)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.addTarget(self, action: #selector(onSend(_:)), for: .touchUpInside)
            sendButtonContainerView.addSubview(button)
            return button
        })
        
        slider.delegate = self
        slider.config(minValue: 0, maxValue: 30, initValue: toleranceFrameCount)
        
        legendView.row = 2
        legendView.col = 3
        legendView.vSpace = kFitHei(13)
        view.addSubview(legendView)
        legendView.updateCell = { [unowned self] cell, index in
            cell.setData(color: self.visualDatas[index].color, text: self.visualDatas[index].label)
        }
        
        view.addSubview(menuView)
        menuView.onClickBlock = { [unowned self] action in
            switch action {
            case .setting:
                let vc = SettingViewController()
                self.navigationController?.present(vc, animated: true, completion: nil)
            case .file:
                self.navigationController?.pushViewController(ProbeFileViewController(), animated: true)
            case .tareOn:
                tarePreData = [:]
            case .tareOff:
                tarePreData = nil
                tareData = nil
            case .function:
                break
            case .startRecord:
                ProbeFileManager.shared.begin()
            case .endRecord:
                ProbeFileManager.shared.finish { success in
                    DispatchQueue.main.async {
                        if success {
                            Toast.showRightNow("文件保存成功")
                        } else {
                            Toast.showRightNow("未写入数据，文件未保存")
                        }
                    }
                }
            }
        }
        
        dynamicDataView.collectionView.clipsToBounds = false
        dynamicDataView.row = 3
        dynamicDataView.col = 3
        dynamicDataView.hSpace = kFitWid(30)
        dynamicDataView.vSpace = kFitHei(12)
        dynamicDataView.updateCell = { [unowned self] cell, index in
            guard let data = self.currentData?.displayData else { return }
            guard data.count > index else {
                cell.setData(nil)
                return
            }
            cell.setData(data[index])
        }
        
        view.addSubview(dynamicDataView)
        dynamicDataView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        
        let appearance = ToastView.appearance()
        appearance.backgroundColor = .alertBackground
        appearance.cornerRadius = 4
        appearance.textColor = .text
        appearance.font = UIFont.systemFont(ofSize: 14)
        
        UDPManager.default.addListener(self)
        setupLegend()
        
        DispatchQueue.global().async {
            ProbeFileManager.shared.load()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        chartView.isPause = false
        legendView.reload()
        dynamicDataView.reload()
        menuView.start()
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UDPManager.default.send("init".data(using: .utf8)!, toHost: "192.168.1.1", port: 3333, tag: 0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        chartView.isPause = true
        menuView.end()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        ToastView.appearance().bottomOffsetPortrait = view.height - view.safeAreaInsets.top - 100
//        topBarView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: 40)
//        recordButton.size = CGSize(width: 60, height: 26)
//        recordButton.rightMargin = 100
//        recordButton.centerYInSuperview()
//        fileButton.size = CGSize(width: 60, height: 26)
//        fileButton.rightMargin = 20
//        fileButton.centerYInSuperview()
//        settingButton.size = CGSize(width: 60, height: 26)
//        settingButton.frame.minX = 20
//        settingButton.centerYInSuperview()
//        tareButton.size = CGSize(width: 60, height: 26)
//        tareButton.frame.minX = settingButton.frame.maxX + 20
//        tareButton.centerYInSuperview()
//        displayDataView.frame = CGRect(x: 0, y: topBarView.frame.maxY, width: view.width, height: 80)
        
        legendView.minY = view.safeAreaInsets.top + kFitHei(8)
        legendView.centerXInSuperview(margin: 18)
        legendView.height = kFitHei(45)
        
        menuView.size = CGSize(width: view.width, height: kFitHei(kFitHei(50)))
        menuView.bottomMargin = view.safeAreaInsets.bottom
        
        dynamicDataView.size = CGSize(width: view.width, height: kFitHei(280))
        dynamicDataView.maxY = menuView.minY
        dynamicDataView.edgeInsets = UIEdgeInsets(top: kFitHei(26), left: kFitWid(14), bottom: kFitHei(26), right: kFitWid(14))
        
        bottomView.width = view.width
        
        var maxButtonY: CGFloat = 0
        
        do {
            let colCount = 3
            let space: CGFloat = 8
            let width: CGFloat = (view.width - space * CGFloat(colCount + 1)) / CGFloat(colCount)
            let height: CGFloat = 30
            
            for (i, button) in legendButtons.enumerated() {
                
                let row = i / colCount
                let col = i % colCount
                
                button.frame = CGRect(x: space + CGFloat(col) * (width + space), y: space + CGFloat(row) * (height + space), width: width, height: height)
                maxButtonY = button.frame.maxY
            }
        }
        
        sendButtonContainerView.frame = CGRect(x: 0, y: maxButtonY + 20, width: view.width, height: 30)
        
        do {
            
            let colCount = 3
            let space: CGFloat = 8
            let width: CGFloat = (sendButtonContainerView.width - space * CGFloat(colCount + 1)) / CGFloat(colCount)
            
            for (i, button) in sendButtons.enumerated() {
                
                let row = i / colCount
                let col = i % colCount
                
                button.frame = CGRect(x: space + CGFloat(col) * (width + space), y: space + CGFloat(row) * (sendButtonContainerView.height + space), width: width, height: sendButtonContainerView.height)
                
            }
        }
        
        slider.height = 60
        slider.minY = sendButtonContainerView.maxY + 30
        slider.centerXInSuperview(margin: 30)
        
        bottomView.height = slider.maxY + view.safeAreaInsets.bottom
        bottomView.bottomMargin = 0

        chartView.frame = CGRect(x: 0, y: legendView.frame.maxY + kFitHei(16), width: view.frame.width, height: dynamicDataView.minY - legendView.maxY - kFitHei(16))

    }
    
    private func setupLegend() {
        
        legendButtons = visualDatas.map({ data -> UIButton in
            let button = UIButton()
            button.setTitle(data.label, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(.black, for: .selected)
            button.isSelected = data.needShow
            button.backgroundColor = data.color
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.addTarget(self, action: #selector(onClickLegend(_:)), for: .touchUpInside)
            bottomView.addSubview(button)
            return button
        })
    }
    
    private func updateDisplayDataView() {
        guard let displayData = self.currentData?.displayData else { return }
        
        let colCount = 3
        let space: CGFloat = 3
        let width: CGFloat = (view.width - space * CGFloat(colCount + 1)) / CGFloat(colCount)
        let height: CGFloat = 30
        
        for (i, data) in displayData.enumerated() {
            
            let label: UILabel
            if i < displayDataLabels.count {
                label = displayDataLabels[i]
            } else {
                label = UILabel()
                label.textColor = .white
                label.font = UIFont.systemFont(ofSize: 12)
                displayDataLabels.append(label)
                displayDataView.addSubview(label)
            }
            
            label.text = data.name + ": " + String(format: "%.1f", data.value)
            
            let row = i / colCount
            let col = i % colCount
            
            label.frame = CGRect(x: space + CGFloat(col) * (width + space), y: CGFloat(row) * (height + space), width: width, height: height)
        }
    }
    
    @objc private func onClickLegend(_ button: UIButton) {
        
        let index = legendButtons.firstIndex(of: button)!
        button.isSelected = !button.isSelected
        visualDatas[index].needShow = !visualDatas[index].needShow
    }
    
    @objc private func onRecord(_ button: UIButton) {
        button.isSelected = !button.isSelected
        button.backgroundColor = button.isSelected ? #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) : #colorLiteral(red: 0.3471153975, green: 0.5619726777, blue: 0.6928223372, alpha: 1)
        if button.isSelected {
            ProbeFileManager.shared.begin()
        } else {
            ProbeFileManager.shared.finish { success in
                DispatchQueue.main.async {
                    if success {
                        Toast.showRightNow("文件保存成功")
                    } else {
                        Toast.showRightNow("未写入数据，文件未保存")
                    }
                }
            }
        }
    }
    
    @objc private func onFile(_ button: UIButton) {
        navigationController?.pushViewController(ProbeFileViewController(), animated: true)
    }
    
    @objc private func onSetting(_ button: UIButton) {
        let vc = SettingViewController()
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @objc private func onTare(_ button: UIButton) {
        button.isSelected = !button.isSelected
        button.backgroundColor = button.isSelected ? #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) : #colorLiteral(red: 0.3471153975, green: 0.5619726777, blue: 0.6928223372, alpha: 1)
        if button.isSelected {
            tarePreData = [:]
        } else {
            tarePreData = nil
            tareData = nil
        }
    }
    
    @objc private func onSend(_ button: UIButton) {
        let index = sendButtons.firstIndex(of: button)!
        let data = sendDatas[index].data(using: .utf8)!
        let result = UDPManager.default.send(data)
        if result {
            Toast.showRightNow("发送成功")
        } else {
            Toast.showRightNow("发送失败，host或port未空")
        }
    }
}


extension MainViewController: UDPListener {

    func didReceive(_ data: Data, fromHost host: String, port: UInt16) {
        ProbeFileManager.shared.write(data)
        let str = String(data: data, encoding: .utf8)!
        let values = str.split(separator: ",").map({ String($0) })
        
        var visualData: [String: Double] = [:]
        let currentDataIndex = Int(Double(values[0])!)
        let wiFiSignalStrength = Int(Double(values[1])!)
        let currentDataFrequency = Int(Double(values[2])!)
        let batteryVoltage = Double(values[3])!

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
        
        visualData["icmAccX"] = Double(values[15])!
        visualData["icmAccY"] = Double(values[16])!
        visualData["icmAccZ"] = Double(values[17])!
        visualData["icmGyrX"] = Double(values[18])!
        visualData["icmGyrY"] = Double(values[19])!
        visualData["icmGyrZ"] = Double(values[20])!
        visualData["currentDataFrequency"] = Double(values[2])!
        visualData["bmpTemperature"] = Double(values[10])!
        visualData["bmpPressure"] = Double(values[11])!
        visualData["pitchAngle"] = Double(values[12])!
        visualData["rollAngle"] = Double(values[13])!
        visualData["yawAngle"] = Double(values[14])!

        var displayData: [DynamicData] = []
        displayData.append(DynamicData(name: "pitchAngle", value: Double(values[12])!, unit: "deg"))
        displayData.append(DynamicData(name: "rollAngle", value: Double(values[13])!, unit: "deg"))
        displayData.append(DynamicData(name: "yawAngle", value: Double(values[14])!, unit: "deg"))
        displayData.append(DynamicData(name: "BT", value: Double(values[10])!, unit: "°C"))
        displayData.append(DynamicData(name: "ATM", value: Double(values[11])!, unit: "kPa"))
//        displayData.append(DynamicData(name: "batteryVoltage", value: Double(values[3])!, unit: ""))

//        let probeData = ProbeData(currentDataIndex: currentDataIndex, visualData: visualData)
        let probeData = ProbeData(currentDataIndex: currentDataIndex, wiFiSignalStrength: wiFiSignalStrength, currentDataFrequency: currentDataFrequency, batteryVoltage: batteryVoltage, windSpeed: 0, windPitching: 0, windYaw: 0, sensorPitch: pitchAngle, sensorRoll: rollAngle, sensoryaw: yawAngle, bmpTemperature: bmpTemperature, bmpPressure: bmpPressure, visualData: visualData, displayData: displayData)
        
        if let tarePreData = tarePreData, (tarePreData.first?.value.count ?? 0) < tarePreDataCount {
            for (key, value) in visualData {
                self.tarePreData![key, default: []].append(value)
            }
            if (self.tarePreData!.first?.value.count ?? 0) == tarePreDataCount {
                self.tareData = Dictionary(uniqueKeysWithValues: self.tarePreData!.map({ ($0, $1.reduce(0, +) / Double(tarePreDataCount)) }))
            }
        }
        
        DispatchQueue.main.async {
            self.currentData = probeData
            self.updateDisplayDataView()
            self.dynamicDataView.reload()
            self.menuView.update(battery: batteryVoltage, wifi: wiFiSignalStrength)
        }
//        let chartDatas = visualDatas.filter({ !$0.values.isEmpty }).map({ ChartData(values: $0.values, color: $0.color) })
//        print("receive", probeData.currentDataIndex)
    }
}

extension MainViewController: ChartViewDataSource {
    
    func chartData(_ chartView: ChartView) -> [String: Double] {
                        
        if !isBegin && currentData != nil {
            isBegin = true
        }
        
        guard isBegin else { return [:] }
        
        #if DEBUG
        if currentData == nil {
            delayFrame += 1
        } else {
            if delayFrame > 0 {
                if delayFrame - 1 < delayFrameList.count {
                    delayFrameList[delayFrame - 1] += 1
                } else {
                    delayFrameList.append(delayFrame)
                }
                print(delayFrameList)
                delayFrame = 0
            }
        }
        #endif
        
        let data: [String: Double]
        
        if let currentData = currentData {
            data = currentData.visualData
            backupData = data
            currentDelayCount = 0
        } else {
            if currentDelayCount < toleranceFrameCount {
                data = backupData!
            } else {
                data = [:]
            }
            currentDelayCount += 1
        }
        
        let selected = visualDatas.filter({ $0.needShow }).map({ $0.label })
        var dataToShow = data.filter({ selected.contains($0.key) })
        if let tareData = tareData {
            dataToShow = Dictionary(uniqueKeysWithValues: dataToShow.map({ ($0, $1 - (tareData[$0] ?? 0)) }))
        }
        currentData = nil
        return dataToShow
        //            let data: [String: Double] = ["differentialPressure0": Double.random(in: 30..<40)]
    }
    
    func lineColor(_ key: String) -> UIColor {
        return colorDict[key]!
    }
}

extension MainViewController: SliderDelegate {
    
    func valueChanged(_ slider: Slider, value: Int) {
        if slider.maxValue == value {
            toleranceFrameCount = Int.max
        } else {
            toleranceFrameCount = value
        }
    }
    
    func displayText(value: Int) -> String {
        if value == slider.maxValue {
            return "Max"
        } else {
            return "\(value)"
        }
    }
}
