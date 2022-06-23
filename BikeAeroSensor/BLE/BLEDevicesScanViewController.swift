//
//  BLEDevicesScanViewController.swift
//  BikeAeroSensor
//
//  Created by shenyutao on 2022/6/17.
//

import UIKit
import CoreBluetooth

class BLEDevicesScanViewController: TitleViewController {
    private static let cellIdentifer = "BLEDeviceCell"
    
    private let manager = BLEManager.sharedInstanced
    private var tableView: UITableView!
    private var scanLoading: UIActivityIndicatorView!
    
    private var devices: [BLEDevice] = [] {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        setupViews()
        manager.register(delegate: self)
        manager.scanning = true
    }
    
    deinit {
        manager.scanning = false
        manager.unRegister(delegate: self)
    }
    
    private func setupViews() {
        title = "Scan Devices"
        navigationItem.backButtonTitle = "back"
        view.backgroundColor = .white
        
        scanLoading = UIActivityIndicatorView(style: .medium)
        scanLoading.color = .theme
        scanLoading.startAnimating()
        titleView.addSubview(scanLoading)
        scanLoading.snp.makeConstraints { make in
            make.right.equalTo(closeButton.snp.left).offset(-12)
            make.centerY.equalTo(closeButton.snp.centerY)
        }
        
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.rowHeight = 50
        tableView.dataSource = self
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(titleView.snp.bottom)
        }
        devices = manager.deveices
        
    }
}

extension BLEDevicesScanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifer) as? discoverdDeviceCell ?? discoverdDeviceCell(style: .default, reuseIdentifier: Self.cellIdentifer)
        let device = devices[indexPath.row]
        cell.updateCell(device)
        return cell
    }
    
    func triggerDeviceConnectState(device: BLEDevice, cell: discoverdDeviceCell) {
        if device.state != .connected {
            device.connect()
        } else {
            BLECommonParams.defaultDeviceUUID = "" // 重设默认蓝牙设备
            device.disconnect()
        }
        cell.refreshLoading()
        manager.disconnectedByUser = true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let device = devices[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) as? discoverdDeviceCell {
            triggerDeviceConnectState(device: device, cell: cell)
        }
    }
}

extension BLEDevicesScanViewController: BLEManagerProtocol {
    func didDiscover(device: BLEDevice) {
        // 刷新发现设备
        devices = manager.deveices
    }
    
    func didScan(on: Bool) {
        // 扫描开关状态变更
        scanLoading.isHidden = !manager.scanning
    }
    
    func didChangedState(state: CBManagerState) {
        // 蓝牙状态变更
        devices = manager.deveices
        if state == .poweredOn {
            manager.scanning = true
        }
    }
    
    func didConnected(_ device: BLEDevice) {
        // 连接到设备回调
        if let index = devices.firstIndex(of: device),
           let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? discoverdDeviceCell {
            cell.refreshLoading()
        }
        manager.disconnectedByUser = false
    }
    
    func didDisconnected(_ device: BLEDevice) {
        // 断开设备回调
        if let index = devices.firstIndex(of: device),
           let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? discoverdDeviceCell {
            cell.refreshLoading()
        }
    }
}

/// tableView cell单元
class discoverdDeviceCell: UITableViewCell {
    private var device: BLEDevice?
    
    private var name: UILabel!
    private var state: UILabel!
    private var loadingView: UIActivityIndicatorView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(_ device: BLEDevice?) {
        self.device = device
        name.text = self.device?.name
        refreshLoading()
    }
    
    func refreshLoading() {
        let showLoading = device?.state == .connecting || device?.state == .disconnecting
        loadingView.isHidden = !showLoading
        if showLoading  {
            loadingView.startAnimating()
        } else {
            loadingView.stopAnimating()
        }
        state.isHidden = showLoading
        state.text = device?.state.stateText
    }
    
    private func setupViews() {
        name = UILabel()
        name.font = UIFont.systemFont(ofSize: 18)
        name.textColor = #colorLiteral(red: 0.2338292599, green: 0.2324454784, blue: 0.2348968685, alpha: 1)
        contentView.addSubview(name)
        name.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.centerY.equalToSuperview()
        }
        
        state = UILabel()
        state.font = UIFont.systemFont(ofSize: 16)
        state.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        contentView.addSubview(state)
        state.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-30)
            make.centerY.equalToSuperview()
        }
        
        loadingView = UIActivityIndicatorView(style: .medium)
        loadingView.isHidden = true
        contentView.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.center.equalTo(state)
        }
    }
}

private extension CBPeripheralState {
    var stateText: String {
        switch self {
        case .disconnected:
            return "disconnected"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        case .disconnecting:
            return "disconnecting"
        @unknown default:
            return "unknown"
        }
    }
}
