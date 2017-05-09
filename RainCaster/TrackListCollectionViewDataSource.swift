//
//  TrackListCollectionViewDataSource.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit

class TrackListCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
	
	// MARK: - properties
	var trackDataArr = [CellData]()
	var settingsCellIdx: Int = 0
	weak var collectionView: UICollectionView?
	var cellWidth: CGFloat {
		return (collectionView?.frame.width ?? 0) * 0.8
	}
	
	// MARK: - UIScrollViewDelegate methods
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let totalOffset = scrollView.contentOffset.x
	}
	
	// MARK: - UICollectionViewDelegateFlowLayout methoda
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 1
	}
	
	

	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		let lateralPadding = (collectionView.frame.width * 0.2) / 2
		return UIEdgeInsets(top: 8, left: lateralPadding, bottom: 8, right: lateralPadding)
//		if section == 0 {
//			return UIEdgeInsets(top: 8, left: lateralPadding, bottom: 8, right: lateralPadding - (cellWidth * 0.15))
//		} else {
//			return UIEdgeInsets(top: 8, left: lateralPadding, bottom: 8, right: lateralPadding)
//		}
		
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let fullSize = collectionView.bounds.size
		return CGSize(width: cellWidth, height: fullSize.height * 0.9)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 40
	}
	

	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cellData = trackDataArr[indexPath.section]
		if cellData is AmbientTrackData {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackCell", for: indexPath) as! AmbientTrackCollectionViewCell
			cell.manifest()
			cell.adopt(data: cellData)
			return cell
		} else if cellData is SettingsCellData {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingsCell", for: indexPath) as! SettingsCollectionViewCell
			cell.adopt(data: cellData)
			return cell
		}
		return UICollectionViewCell()
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		let count = trackDataArr.count
		collectionView.contentSize = CGSize(width: CGFloat(count) * collectionView.frame.width, height: collectionView.frame.height)
		return count
	}
	
	// MARK: - methods
	func insertSettingsCell(atIdx idx: Int? = nil) {
		let idx = idx ?? trackDataArr.count
		guard idx >= 0 && idx <= trackDataArr.count else {
			return
		}
		let settingsCell = SettingsCellData()
		trackDataArr.insert(settingsCell, at: idx)
		
	}
	
	func fillWithFakeData() {
		trackDataArr = DummyDataSource.themedTrackCells()
		insertSettingsCell() // at end
	}
	
	func adopt(collectionView: UICollectionView) {
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(UINib(nibName: "AmbientTrackCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "TrackCell")
		collectionView.register(UINib(nibName: "SettingsCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SettingsCell")
		collectionView.isPagingEnabled = true
		self.collectionView = collectionView
		
		// TODO: remove
		fillWithFakeData()
	}
	
}
