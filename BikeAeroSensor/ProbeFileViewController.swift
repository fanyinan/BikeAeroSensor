//
//  ProbeFileViewController.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/21.
//

import UIKit
import Zip
import PathKit

class ProbeFileViewController: TitleViewController {

    private var fileList: [ProbeFileInfo] = []
    private let editButton = UIButton()
    private let shareButton = UIButton()
    private let deleteButton = UIButton()
    private let selectAllButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        title = "Files"
        navigationItem.backButtonTitle = "back"
        view.addSubview(tableView)
        view.backgroundColor = .white
        reload()
        
        titleView.addSubview(editButton)
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitle("Cancel", for: .selected)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        editButton.setTitleColor(.theme, for: .normal)
        editButton.addTarget(self, action: #selector(onEdit), for: .touchUpInside)
        editButton.snp.makeConstraints { make in
            make.right.equalTo(closeButton.snp.left).offset(-12)
            make.centerY.equalTo(closeButton.snp.centerY)
        }
        
        titleView.addSubview(shareButton)
        shareButton.isHidden = true
        shareButton.setTitle("Share", for: .normal)
        shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        shareButton.setTitleColor(.theme, for: .normal)
        shareButton.addTarget(self, action: #selector(onShare), for: .touchUpInside)
        shareButton.snp.makeConstraints { make in
            make.right.equalTo(editButton.snp.left).offset(-12)
            make.centerY.equalTo(editButton.snp.centerY)
        }
        
        titleView.addSubview(deleteButton)
        deleteButton.isHidden = true
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        deleteButton.setTitleColor(.theme, for: .normal)
        deleteButton.addTarget(self, action: #selector(onDelete(_:)), for: .touchUpInside)
        deleteButton.snp.makeConstraints { make in
            make.right.equalTo(shareButton.snp.left).offset(-12)
            make.centerY.equalTo(shareButton.snp.centerY)
        }
        
        titleView.addSubview(selectAllButton)
        selectAllButton.isHidden = true
        selectAllButton.setTitle("Select all", for: .normal)
        selectAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        selectAllButton.setTitleColor(.theme, for: .normal)
        selectAllButton.addTarget(self, action: #selector(onSelectAll(_:)), for: .touchUpInside)
        selectAllButton.snp.makeConstraints { make in
            make.right.equalTo(deleteButton.snp.left).offset(-12)
            make.centerY.equalTo(deleteButton.snp.centerY)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = CGRect(x: 0, y: titleView.maxY, width: view.width, height: view.height - titleView.maxY)
    }
    
    func reload() {
        fileList = ProbeFileManager.shared.fileInfos.reversed()
        tableView.reloadData()
    }
    
    @objc private func onEdit(_ button: UIButton) {
        guard !fileList.isEmpty || button.isSelected else { return }
        button.isSelected = !button.isSelected
        tableView.isEditing = !tableView.isEditing
        deleteButton.isHidden = !deleteButton.isHidden
        shareButton.isHidden = !shareButton.isHidden
        selectAllButton.isHidden = !selectAllButton.isHidden
    }
    
    @objc private func onDelete(_ button: UIButton) {
        guard let indexPaths = tableView.indexPathsForSelectedRows, !indexPaths.isEmpty else { return }
        let alertView = AlertView(title: nil, message: "Confirm delete?", markButtonTitle: "Yes", otherButtonTitles: "Cancel")
        alertView.show().onSucceed {
            ProbeFileManager.shared.delete(indexPaths.map({ self.fileList[$0.row] })) {
                DispatchQueue.main.async {
                    self.reload()
                }
            }
        }
    }
    
    @objc private func onShare(_ button: UIButton) {
        guard let indexPaths = tableView.indexPathsForSelectedRows, !indexPaths.isEmpty else { return }
        shareFile(indexPaths: indexPaths)
    }
    
    @objc private func onSelectAll(_ button: UIButton) {
        (0..<fileList.count).forEach({ tableView.selectRow(at: IndexPath(row: $0, section: 0), animated: false, scrollPosition: .none) })
    }
    
    private func shareFile(indexPaths: [IndexPath]) {
        
        guard !indexPaths.isEmpty else { return }
        
        var files: [ProbeFileInfo] = []
        
        for indexPath in indexPaths {
            let file = fileList[indexPath.row]
            if !file.filePath.exists {
                Toast.showRightNow("No data was selected.: \(file.displayName)")
                return
            }
            files.append(file)
        }
        let archiveFiles = convertToCSVArchiveFiles(infos: files)
        let zipURL = Path.temporary + Path(files.first!.displayName + ".zip")
        do {
            try Zip.zipData(archiveFiles: archiveFiles, zipFilePath: zipURL.url, password: nil, progress: nil)
        } catch let error {
            Toast.showRightNow(error.localizedDescription)
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [zipURL.url], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { (type: UIActivity.ActivityType?, success: Bool, info: [Any]?, error: Error?) in
            guard success else { return }
            files.forEach({ $0.markSent() })
            ProbeFileManager.shared.save()
            self.reload()
        }
        
        present(activityVC, animated: true, completion: nil)
    }
    
    private func convertToCSVArchiveFiles(infos: [ProbeFileInfo]) -> [ArchiveFile] {
        let datas = infos.compactMap { info in
            let fileURL = info.filePath.url
            do {
                let data = try Data(contentsOf: fileURL)
                let dataString = String(data: data, encoding: .utf8)
                let endOfHeaderRange = dataString?.range(of: "***End_of_Header***")
                let suffixCSVString = dataString?.suffix(from: endOfHeaderRange!.upperBound).trimmingCharacters(in: .whitespacesAndNewlines)
                let csvData = suffixCSVString?.data(using: .utf8)
                if let csvData = csvData { return (info, csvData) }
                return nil
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        return datas.compactMap {
            ArchiveFile(filename: $0.displayName.appending(".csv"), data: $1 as NSData, modifiedTime: nil)
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellType: ProbeFileCell.self)
        tableView.rowHeight = 60
        tableView.separatorColor = .separator
        tableView.separatorInset = .zero
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        return tableView
    }()
}


extension ProbeFileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ProbeFileCell.self)
        cell.setData(fileList[indexPath.row])
        return cell
    }
}

extension ProbeFileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.isEditing else { return }
        shareFile(indexPaths: [indexPath])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let fileInfo = fileList[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "删除", handler: { (action, view, config) in
            ProbeFileManager.shared.delete([fileInfo], completion: {
                DispatchQueue.main.async {
                    CATransaction.begin()
                    CATransaction.setCompletionBlock({
                        self.reload()
                    })
                    config(true)
                    CATransaction.commit()
                }
            })
        })

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle(rawValue: UITableViewCell.EditingStyle.delete.rawValue | UITableViewCell.EditingStyle.insert.rawValue)!
    }
}
