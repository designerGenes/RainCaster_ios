//
//  TrackListCollectionViewDataSource.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit

class TrackListCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	// MARK: - properties
	var trackDataArr = [CellData]()
	
	
	// MARK: - UICollectionViewDelegateFlowLayout methoda
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cellData = trackDataArr[indexPath.section]
		let cell = cellData.asCell()
		return cell
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return trackDataArr.count
	}
	
	// MARK: - methods
	func insertSettingsCell(atIdx idx: Int? = nil) {
		let idx = idx ?? trackDataArr.count
		guard idx >= 0 && idx <= trackDataArr.count else {
			return
		}		
	}
	
	func fillWithFakeData() {
		trackDataArr = DummyDataSource.themedTrackCells()
		insertSettingsCell() // at end
	}
	
	func adopt(collectionView: UICollectionView) {
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(UINib(nibName: "ThemedTrackCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "TrackCell")
		collectionView.register(UINib(nibName: "SettingsCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SettingsCell")
	}
	
}
