//
//  MainViewController.swift
//  BikeAeroSensor
//
//  Created by yinan17 on 2021/8/18.
//

import UIKit
import CoreBluetooth

class MainViewController: UIViewController {

    private let chartView = ChartView()
    private let topBarView = UIView()
    private let recordButton = UIButton()
    private let fileButton = UIButton()
    private let settingButton = UIButton()
    private let tareButton = UIButton()
    private let displayDataView = UIView()
    private let bottomView = UIView()
    private let sendButtonContainerView = UIView()
    private var sendButtons: [UIButton] = []
    private let legendView = GridView(cellType: LegendCell.self)
    private let menuView = MenuView.loadFromNib()
    private let dynamicDataView = GridView(cellType: DynamicDataCell.self)
    private let rightTopImageView = UIImageView()
    
    private var currentData: ProbeData?
    private var currentDynamicData: ProbeData?
    private var toleranceFrameCount = 5

    private var isBegin = false
    private var currentDelayCount = 0
    private var backupData: [DataName: Double]?
    
    private var tarePreData: [DataName: [Double]]?
    private let tarePreDataCount = 10
    private var tareData: [DataName: Double]?
    
    private var extraDataName: DataName?
    
    private lazy var lastBLEReceiveBLEValues: [DataName: Double] = [:] // 缓存蓝牙设备接收的数据
    private var lastBLERefreshTime: CFTimeInterval = 0 // 蓝牙接收数据上一次刷新界面的时间
    private let refreshInterval = 0.05 // 蓝牙接收数据的刷新时间
    /// 图表显示的接收类型，互斥，默认显示UDP类型
    private lazy var displayType: DisplayReceiveType = .UDP  {
        didSet {
            guard displayType != oldValue else { return }
        }
    }

    #if DEBUG
    private var delayFrame = 0
    private var delayFrameList = [Int](repeating: 0, count: 20)
    #endif

    private var datas: [DataInfo] = [
        DataInfo(label: .currentDataIndex, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), unit: "", isVisual: false, isDisplay: false),
        DataInfo(label: .wiFiSignalStrength, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), unit: "%", isVisual: false, isDisplay: false),
        DataInfo(label: .currentDataFrequency, color: #colorLiteral(red: 0.2671898305, green: 1, blue: 0.5297580957, alpha: 1), unit: "Hz", isVisual: true, isDisplay: false),
        DataInfo(label: .batteryVoltage, color: #colorLiteral(red: 0.2671898305, green: 1, blue: 0.5297580957, alpha: 1), unit: "V", isVisual: false, isDisplay: false),
        DataInfo(label: .differentialPressure0, color: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), unit: "Pa", isVisual: true, isDisplay: false),
        DataInfo(label: .differentialPressure1, color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), unit: "Pa", isVisual: true, isDisplay: false),
        DataInfo(label: .differentialPressure2, color: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), unit: "Pa", isVisual: true, isDisplay: false),
        DataInfo(label: .differentialPressure3, color: #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), unit: "Pa", isVisual: true, isDisplay: false),
        DataInfo(label: .differentialPressure4, color: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), unit: "Pa", isVisual: true, isDisplay: false),
        DataInfo(label: .averageDPTemperature, color: #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), unit: "Pa", isVisual: true, isDisplay: false),
        DataInfo(label: .bmpTemperature, color: #colorLiteral(red: 0.6042316556, green: 0.09232855588, blue: 0.2760148644, alpha: 1), unit: "°C", isVisual: true, isDisplay: true),
        DataInfo(label: .bmpPressure, color: #colorLiteral(red: 0.9821859002, green: 0.489916265, blue: 0.2320583761, alpha: 1), unit: "kPa", isVisual: true, isDisplay: true),
        DataInfo(label: .pitchAngle, color: #colorLiteral(red: 0.820196569, green: 0.85434407, blue: 0, alpha: 1), unit: "deg", isVisual: true, isDisplay: true),
        DataInfo(label: .rollAngle, color: #colorLiteral(red: 0.1820499003, green: 0.5240936279, blue: 0.9926010966, alpha: 1), unit: "deg", isVisual: true, isDisplay: true),
        DataInfo(label: .yawAngle, color: #colorLiteral(red: 0.8631967902, green: 0.1063003018, blue: 0.9723851085, alpha: 1), unit: "deg", isVisual: true, isDisplay: true),
        DataInfo(label: .icmAccX, color: #colorLiteral(red: 0.5810584426, green: 0.1285524964, blue: 0.5745313764, alpha: 1), unit: "m/s^2", isVisual: true, isDisplay: false),
        DataInfo(label: .icmAccY, color: #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1), unit: "m/s^2", isVisual: true, isDisplay: false),
        DataInfo(label: .icmAccZ, color: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), unit: "m/s^2", isVisual: true, isDisplay: false),
        DataInfo(label: .icmGyrX, color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), unit: "rad/S^2", isVisual: true, isDisplay: false),
        DataInfo(label: .icmGyrY, color: #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), unit: "rad/S^2", isVisual: true, isDisplay: false),
        DataInfo(label: .icmGyrZ, color: #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1), unit: "rad/S^2", isVisual: true, isDisplay: false),
        DataInfo(label: .windSpeed, color: #colorLiteral(red: 0, green: 0.8661341071, blue: 0.1548731029, alpha: 1), unit: "m/s", isVisual: true, isDisplay: true),
        DataInfo(label: .windPitch, color: #colorLiteral(red: 1, green: 0.3544633389, blue: 0.6672851443, alpha: 1), unit: "deg", isVisual: true, isDisplay: true),
        DataInfo(label: .windYaw, color: #colorLiteral(red: 0.9873083234, green: 0.6549053788, blue: 0, alpha: 1), unit: "deg", isVisual: true, isDisplay: true),
    ]
    
    let displayDataOrder: [DataName] = [.windSpeed, .windPitch, .windYaw, .pitchAngle, .rollAngle, .yawAngle, .bmpTemperature, .bmpPressure]
    
    private lazy var colorDict: [DataName: UIColor] = {
        return Dictionary(uniqueKeysWithValues: datas.map{ ($0.label, $0.color) })
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .theme

        view.addSubview(chartView)
        chartView.dataSource = self
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        
        view.addSubview(rightTopImageView)
        rightTopImageView.contentMode = .scaleAspectFill
        rightTopImageView.image = UIImage(named: "bike")
        
        legendView.row = 2
        legendView.col = 3
        legendView.vSpace = kFitHei(13)
        view.addSubview(legendView)
        legendView.updateCell = { [unowned self] cell, index in
            let datas = self.datas.filter({ $0.needShow })
            if datas.count > index {
                cell.setData(datas[index])
            } else {
                cell.setData(nil)
            }
        }
        
        view.addSubview(menuView)
        menuView.onClickBlock = { [unowned self] action in
            switch action {
            case .setting:
                self.clickSetting()
            case .file:
                self.present(ProbeFileViewController(), animated: true, completion: nil)
            case .tareOn:
                tarePreData = [:]
            case .tareOff:
                tarePreData = nil
                tareData = nil
            case .function:
                break
            case .startRecord:
                Toast.showRightNow("Start logging.")
                ProbeFileManager.shared.begin()
            case .endRecord:
                ProbeFileManager.shared.finish { success in
                    DispatchQueue.main.async {
                        if success {
                            Toast.showRightNow("File saved.")
                        } else {
                            Toast.showRightNow("No data was received.")
                        }
                    }
                }
            }
        }
        
        dynamicDataView.collectionView.clipsToBounds = false
        dynamicDataView.row = 3
        dynamicDataView.col = 3
        dynamicDataView.hSpace = kFitWid(8)
        dynamicDataView.vSpace = kFitHei(8)
        dynamicDataView.updateCell = { [unowned self] cell, index in
            guard let data = self.currentDynamicData?.displayData else {
                cell.setData(nil, showAddWhenEmpty: index == 8)
                return
            }
            guard data.count > index else {
                cell.setData(nil, showAddWhenEmpty: index == 8)
                return
            }
            cell.setData(data[index], showAddWhenEmpty: index == 8)
        }
        
        dynamicDataView.onClick = { [unowned self] cell, index in
            guard index == 8 else { return }
            let vc = DataSelectViewController()
            vc.selectedBlock = { [unowned self] name in
                self.extraDataName = name
            }
            let titles = datas.filter({ $0.isVisual }).map({ $0.label })
            vc.reload(titles, selectedName: extraDataName)
            self.present(vc, animated: true, completion: nil)
        }
        
        view.addSubview(dynamicDataView)
        dynamicDataView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        
        let appearance = ToastView.appearance()
        appearance.backgroundColor = .alertBackground
        appearance.cornerRadius = 4
        appearance.textColor = .text
        appearance.font = UIFont.systemFont(ofSize: 14)
        
        UDPManager.default.addListener(self)
        BLEManager.sharedInstanced.register(delegate: self)
        
        DispatchQueue.global().async {
            ProbeFileManager.shared.load()
        }
        
        view.bringSubviewToFront(menuView)
        menuView.functionView.visualInfos = datas.filter({ $0.isVisual })
        menuView.functionView.onUpdate = { [unowned self] in
            self.legendView.reload()
        }
        
        menuView.functionView.onSetTolerance = { [unowned self] toleranceFrameCount in
            self.toleranceFrameCount = toleranceFrameCount
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        ToastView.appearance().bottomOffsetPortrait = view.safeAreaInsets.bottom + 120

        rightTopImageView.size = CGSize(width: 30, height: 30)
        rightTopImageView.rightMargin = 20
        rightTopImageView.minY = view.safeAreaInsets.top
        
        legendView.minY = view.safeAreaInsets.top + kFitHei(8)
        legendView.centerXInSuperview(margin: 18)
        legendView.height = kFitHei(45)
        
        menuView.size = CGSize(width: view.width, height: kFitHei(kFitHei(50)))
        menuView.bottomMargin = view.safeAreaInsets.bottom
        
        dynamicDataView.size = CGSize(width: view.width, height: kFitHei(280))
        dynamicDataView.maxY = menuView.minY
        dynamicDataView.edgeInsets = UIEdgeInsets(top: kFitHei(26), left: kFitWid(8), bottom: kFitHei(26), right: kFitWid(8))
        
        bottomView.width = view.width
        
        bottomView.height = view.safeAreaInsets.bottom
        bottomView.bottomMargin = 0

        chartView.frame = CGRect(x: 0, y: legendView.frame.maxY + kFitHei(16), width: view.frame.width, height: dynamicDataView.minY - legendView.maxY - kFitHei(16))

        menuView.menuItemHeight = view.height - chartView.convert(CGPoint(x: 0, y: chartView.height), to: nil).y + 40
    }
}


extension MainViewController: UDPListener {

    func didReceive(_ data: Data, fromHost host: String, port: UInt16) {
        guard displayType == .UDP else { return }
        ProbeFileManager.shared.write(data)
        let str = String(data: data, encoding: .utf8)!
        handler(str)
//        let chartDatas = visualDatas.filter({ !$0.values.isEmpty }).map({ ChartData(values: $0.values, color: $0.color) })
//        print("receive", probeData.currentDataIndex)
    }
}

extension MainViewController: BLEManagerProtocol, BLEDeviceDelegte {
    func didConnected(_ device: BLEDevice) {
        /// 连接到蓝牙设备，则注册设备监听，重设显示数据来源
        device.register(delegate: self)
        displayType = .BLE
    }
    
    func didDisconnected(_ device: BLEDevice) {
        device.unRegister(delegate: self)
        lastBLEReceiveBLEValues = [:]
    }
    
    func deviceValueDidChanged(characteristicUUIDString: String, value: Data?) {
        guard displayType == .BLE else { return }
        guard let data = value else { return }
        ProbeFileManager.shared.write(data)
        if characteristicUUIDString == BLECommonParams.BatteryCharacteristicUUIDString {
            let str = data.map { String($0) }.joined(separator: "") // 电池数据不用转ascii码
            debugLog("Device Delagate receive \(str) for \(characteristicUUIDString)")
            DispatchQueue.main.async {
                self.menuView.set(battery: (Double(str) ?? 0) / 100)
            }
        } else if characteristicUUIDString == BLECommonParams.DeviceDataCharacteristicUUIDString {
            let str = data.map { String(format: "%c", $0) }.joined(separator: "") // 自定义数据转ascii码
            debugLog("Device Delagate receive \(str) for \(characteristicUUIDString)")
            handler(str)
        }
    }
}


extension MainViewController: ChartViewDataSource {
    
    func chartData(_ chartView: ChartView) -> [DataName: Double] {
                        
        dynamicDataView.reload()

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
        
        let data: [DataName: Double]
        
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
        
        let selected = datas.filter({ $0.needShow }).map({ $0.label })
        var dataToShow = data.filter({ selected.contains($0.key) })
        if let tareData = tareData {
            dataToShow = Dictionary(uniqueKeysWithValues: dataToShow.map({ ($0, $1 - (tareData[$0] ?? 0)) }))
        }
        currentData = nil
        return dataToShow
        //            let data: [String: Double] = ["differentialPressure0": Double.random(in: 30..<40)]
    }
    
    func lineColor(_ key: DataName) -> UIColor {
        return colorDict[key]!
    }
}

extension MainViewController {
    private func handler(_ receivedString: String) {
        let values = receivedString.split(separator: ",").map { String($0) }
        
        var visualData: [DataName: Double] = [:]
        var displayData: [DynamicData] = []

        for (index, dataInfo) in datas.enumerated() {
            let value: Double
            if index < values.count {
                value = Double(values[index]) ?? 0
            } else {
                if dataInfo.label == .windSpeed {
                    value = sqrt(max(visualData[.differentialPressure0] ?? 0 * 2 / 1.125, 0))
                } else if dataInfo.label == .windPitch {
                    value = visualData[.pitchAngle] ?? 0 - 0.2
                } else if dataInfo.label == .windYaw {
                    value = visualData[.pitchAngle] ?? 0 + 0.1
                } else if dataInfo.label == .bmpPressure {
                    value = (visualData[.bmpPressure] ?? 0) / 1000
                } else {
                    value = 0
                }
            }

            if dataInfo.isVisual {
                visualData[dataInfo.label] = value
            }
            
            if dataInfo.isDisplay {
                displayData.append(DynamicData(name: dataInfo.label, value: value, unit: dataInfo.unit))
            }
        }
        
        let wiFiSignalStrength = values.indices.contains(1) ? Int(Double(values[1]) ?? 0) : 0
        let batteryVoltage = values.indices.contains(3) ? Double(values[3]) ?? 0 : 0
        
        displayData.sort(by: { self.displayDataOrder.firstIndex(of: $0.name)! < self.displayDataOrder.firstIndex(of: $1.name)! })
        
        if let name = extraDataName, let value = visualData[name] {
            displayData.append(DynamicData(name: name, value: value, unit: datas.filter({ $0.label == name }).first!.unit))
        }

        let probeData = ProbeData(visualData: visualData, displayData: displayData)
        
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
            self.currentDynamicData = probeData
            if batteryVoltage > 0 && wiFiSignalStrength > 0 {
                self.menuView.update(battery: batteryVoltage, wifi: wiFiSignalStrength)
            }
        }
    }
    
    private func clickSetting() {
        let alertView = AlertView(title: "设置数据来源", message: "当前数据来源：\(displayType.typeString)\n请选择新的数据来源", markButtonTitle: "取消", otherButtonTitles: "网络", "蓝牙")
        alertView.onSucceed { [unowned alertView] in
            alertView.hide()
        }
        alertView.onResult { [unowned self] index in
            if index == 0 {
                let vc = SettingViewController()
                vc.bindAction = { [weak self] in
                    guard let self = self else { return }
                    if $0 {
                        /// 绑定udp端口成功，重设显示数据来源为udp
                        self.displayType = .UDP
                    }
                }
                self.present(vc, animated: true)
            } else if index == 1 {
                self.present(BLEDevicesScanViewController(), animated: true)
            }
        }
        alertView.show()
    }
}

/// 图表显示的接收类型
private enum DisplayReceiveType: Int {
    case BLE = 1               // 显示蓝牙接收的数据
    case UDP = 2               // 显示UDP接收的数据
}

private extension DisplayReceiveType {
    var typeString: String {
        switch self {
        case .BLE:
            return "蓝牙"
        case .UDP:
            return "网络"
        }
    }
}
