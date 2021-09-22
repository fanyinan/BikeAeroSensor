//
//  FunctionMenuItem.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/26.
//

import UIKit

class FunctionMenuItem: MenuItemView {

    private let slider = Slider()
    private var toleranceFrameCount = 5

    var visualInfos: [DataInfo] = []
        
    var onUpdate: (() -> Void)?
    var onSetTolerance: ((Int) -> Void)?

    override init() {
        super.init()
        
        contentView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.9647058824, alpha: 1)
        
        contentView.addSubview(collectionView)
        
        contentView.addSubview(slider)
    
        slider.delegate = self
        slider.config(minValue: 0, maxValue: 30, initValue: toleranceFrameCount)
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

        slider.height = 30
        slider.bottomMargin = 0
        slider.centerXInSuperview(margin: 30)
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

        guard visualInfos.filter({ $0.needShow }).count < 6 || data.needShow else {
            Toast.showRightNow("最多选择6项")
            return
        }
        
        data.needShow = !data.needShow
        collectionView.reloadData()
        onUpdate?()
    }
}

extension FunctionMenuItem: SliderDelegate {
    
    func valueChanged(_ slider: Slider, value: Int) {
        if slider.maxValue == value {
            toleranceFrameCount = Int.max
        } else {
            toleranceFrameCount = value
        }
        onSetTolerance?(toleranceFrameCount)
    }
    
    func displayText(value: Int) -> String {
        if value == slider.maxValue {
            return "Max"
        } else {
            return "\(value)"
        }
    }
}
