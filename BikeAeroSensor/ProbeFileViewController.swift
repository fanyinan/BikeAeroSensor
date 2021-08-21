//
//  ProbeFileViewController.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/21.
//

import UIKit
import Zip
import PathKit

class ProbeFileViewController: UIViewController {

    private var fileList: [ProbeFileInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        title = "文件"
        navigationItem.backButtonTitle = "返回"
        view.addSubview(tableView)
        view.backgroundColor = .white
        fileList = ProbeFileManager.shared.fileInfos.reversed()
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellType: ProbeFileCell.self)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = 70
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
        let url = fileList[indexPath.row].fileURL
        let zipURL = Path.temporary + Path(url.lastPathComponent + ".zip")
        do {
            try Zip.zipFiles(paths: [url], zipFilePath: zipURL.url, password: nil, progress: nil)
            let activityVC = UIActivityViewController(activityItems: [zipURL.url], applicationActivities: nil)
            navigationController?.present(activityVC, animated: true, completion: nil)
        } catch let error {
            print(error)
        }
        
    }
    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
//        let renameAction = UIContextualAction(style: .normal, title: "重命名", handler: { (action, view, config) in
//            self.rename(index: indexPath.row)
//            config(true)
//        })
//
//        renameAction.backgroundColor = .orange
//
//        let deleteAction = UIContextualAction(style: .destructive, title: "删除", handler: { (action, view, config) in
//            AudioManager.shared.delete(self.audioList[indexPath.row])
//            CATransaction.begin()
//            CATransaction.setCompletionBlock({
//                self.reload()
//            })
//            config(true)
//            CATransaction.commit()
//        })
//
//        return UISwipeActionsConfiguration(actions: [deleteAction, renameAction, topAction])
//    }
}
