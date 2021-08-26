//
//  FunctionMenuItem.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/26.
//

import UIKit

class FunctionMenuItem: MenuItemView {

    var visualInfos: [VisualInfo] = []
        
    var onUpdate: (() -> Void)?
    
    override init() {
        super.init()
        
        contentView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.9647058824, alpha: 1)
        
        contentView.addSubview(collectionView)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
        collectionView.minY = 8
        let col = 3
        let itemWidth = (contentView.width - flowLayout.minimumInteritemSpacing * CGFloat(col - 1) - collectionView.contentInset.left - collectionView.contentInset.right) / CGFloat(col)
        flowLayout.itemSize = CGSize(width: itemWidth, height: 36)
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(cellType: ChartDataItemCell.self)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        return collectionView
    }()

    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 12
        flowLayout.minimumInteritemSpacing = 18
        return flowLayout
    }()
}


extension FunctionMenuItem: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visualInfos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ChartDataItemCell.self)
        let visualInfo = visualInfos[indexPath.row]
        cell.setData(visualInfo)
        return cell
    }
}

extension FunctionMenuItem: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = visualInfos[indexPath.row]
        data.needShow = !data.needShow
        collectionView.reloadData()
        onUpdate?()
    }
}
