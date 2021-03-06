//
//  GridView.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/24.
//

import UIKit

class GridCell: UICollectionViewCell, Reusable {
    
}

class GridView<T: GridCell>: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let cellType: T.Type
    private var cells: [T?] = []
    
    var hSpace: CGFloat = 0
    var vSpace: CGFloat = 0
    var cellSize: CGSize?
    var row = 0 {
        didSet {
            cells = [T?](repeating: nil, count: row * col)
        }
    }
    
    var col = 0 {
        didSet {
            cells = [T?](repeating: nil, count: row * col)
        }
    }
    var edgeInsets = UIEdgeInsets.zero
    
    var updateCell: ((T, Int) -> Void)?
    var onClick: ((T, Int) -> Void)?
    
    init(cellType: T.Type) {
        self.cellType = cellType
        super.init(frame: .zero)
        addSubview(collectionView)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        flowLayout.minimumLineSpacing = vSpace
        flowLayout.minimumInteritemSpacing = hSpace
        collectionView.frame = CGRect(x: edgeInsets.left, y: edgeInsets.top, width: width - edgeInsets.left - edgeInsets.right, height: height - edgeInsets.top - edgeInsets.bottom)
        let itemWidth = (collectionView.width - hSpace * CGFloat(col - 1)) / CGFloat(col)
        let itemHeight = (collectionView.height - vSpace * CGFloat(row - 1)) / CGFloat(row)
        flowLayout.itemSize = CGSize(width: itemWidth.rounded(.down), height: itemHeight)
//        collectionView.contentInset = UIEdgeInsets(top: 0, left: popButton.maxX + 12, bottom: 0, right: 20)
    }
   
    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(cellType: cellType)
        return collectionView
    }()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        return flowLayout
    }()

    func reload() {
        collectionView.reloadData()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let r = super.hitTest(point, with: event)
        return r
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return row * col
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: T
        if let storeCell = cells[indexPath.row] {
            cell = storeCell
        } else {
            cell = collectionView.dequeueReusableCell(for: indexPath, cellType: cellType)
            cells[indexPath.row] = cell
        }
        
        updateCell?(cell, indexPath.row)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onClick?(cells[indexPath.row]!, indexPath.row)
    }
}
