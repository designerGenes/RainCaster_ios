//
//  TrackListCollectionViewDataSource.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class TrackListCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
	
	// MARK: - properties
	static var sharedInstance = TrackListCollectionViewDataSource()
	var cellDataArr = [CellData]()
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
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let fullSize = collectionView.bounds.size
		return CGSize(width: cellWidth, height: fullSize.height * 0.9)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 40
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cellData = cellDataArr[indexPath.section]
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
		let count = cellDataArr.count
		collectionView.contentSize = CGSize(width: CGFloat(count) * collectionView.frame.width, height: collectionView.frame.height)
		return count
	}
	
	// MARK: - methods
	func insertSettingsCell(atIdx idx: Int? = nil) {
		let idx = idx ?? cellDataArr.count
		guard idx >= 0 && idx <= cellDataArr.count else {
			return
		}
		let settingsCell = SettingsCellData()
		cellDataArr.insert(settingsCell, at: idx)
		
	}
	
	
	func absorbTrackData(fromJSON json: JSON) {
		var outList = [CellData]()
		if let trackArr = json.array {
			for track in trackArr {
				let newTrackData = AmbientTrackData(fromJSON: track)
				outList.append(newTrackData)
			}
		}
		cellDataArr = outList
		insertSettingsCell()
		
		collectionView?.reloadData()
	}
	
	func adopt(collectionView: UICollectionView) {
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(UINib(nibName: "AmbientTrackCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "TrackCell")
		collectionView.register(UINib(nibName: "SettingsCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SettingsCell")
		collectionView.isPagingEnabled = true
		self.collectionView = collectionView
	}
	
}
