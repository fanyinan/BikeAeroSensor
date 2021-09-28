//
//  DataSelectViewController.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/28.
//


import UIKit
import Zip
import PathKit

class DataSelectCell: UITableViewCell, Reusable {
    
    private let titleLabel = UILabel()
    private let markImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(markImageView)
        markImageView.image = UIImage(named: "select")?.tintColor(.theme)
        markImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.left.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = #colorLiteral(red: 0.2338292599, green: 0.2324454784, blue: 0.2348968685, alpha: 1)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(markImageView.snp.right).offset(18)
            make.centerY.equalToSuperview()
        }
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setData(_ title: String, isSelected: Bool) {
        titleLabel.text = title
        markImageView.isHidden = !isSelected
    }
}

class DataSelectViewController: TitleViewController {

    private var dataNames: [DataName] = []
    private(set) var selectedName: DataName?
    
    var selectedBlock: ((DataName) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select data"
        view.addSubview(tableView)
        view.backgroundColor = .white
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = CGRect(x: 0, y: titleView.maxY, width: view.width, height: view.height - titleView.maxY)
    }
    
    func reload(_ dataNames: [DataName], selectedName: DataName?) {
        self.dataNames = dataNames
        self.selectedName = selectedName
        tableView.reloadData()
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellType: DataSelectCell.self)
        tableView.rowHeight = 40
        tableView.separatorColor = .clear
        tableView.separatorInset = .zero
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        return tableView
    }()
}


extension DataSelectViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: DataSelectCell.self)
        cell.setData(dataNames[indexPath.row].rawValue, isSelected: dataNames[indexPath.row] == selectedName)
        return cell
    }
}

extension DataSelectViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedName = dataNames[indexPath.row]
        self.selectedName = selectedName
        tableView.reloadData()
        selectedBlock?(selectedName)
    }
    
}
