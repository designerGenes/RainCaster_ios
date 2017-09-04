//
//  AmbientTrackDataSource.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class AmbientTrackDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
	
	// MARK: - properties
	static var sharedInstance = AmbientTrackDataSource()
	var cellDataArr = [CellData]()
	weak var collectionView: UICollectionView?
	var cellWidth: CGFloat {
		return (collectionView?.frame.width ?? 0) * 0.75
	}
	
	
	// MARK: - UICollectionViewDelegateFlowLayout methoda
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		let lateralPadding = (collectionView.frame.width - cellWidth) / 2
		return UIEdgeInsets(top: 24, left: lateralPadding, bottom: 8, right: lateralPadding)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let fullSize = collectionView.bounds.size
		return CGSize(width: cellWidth, height: fullSize.height * 0.9)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
	
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cellData = cellDataArr[indexPath.section]
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackCell", for: indexPath) as? AmbientTrackCollectionViewCell {
			cell.adopt(data: cellData)
			cell.manifest()
			
//			print((cellData as? AmbientTrackData)?.sourceURL ?? "no source url")
			if DJAudioPlaybackController.sharedInstance.isFocusedOn(item: cellData as! AmbientTrackData) &&
				DJAudioPlaybackController.sharedInstance.getAudioPlayerState() == .playing {
//					cell.controlCycler?.reflactState(playbackState: .playing)
			}
            
            
			
			return cell
		}
		return UICollectionViewCell()
	}
    
    
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let cell = cell as? AmbientTrackCollectionViewCell, let assocTrackData = cell.assocTrackData {
            
            if let resString = cell.assocTrackData?.category?.assocResourceString() {
                if let parentView = AppDelegate.shared?.mainPlayerVC?.view, DJVideoBackgroundController.sharedInstance.bgPlayer.currentItem == nil {
                    DJVideoBackgroundController.sharedInstance.manifest(in: parentView)
                    DJVideoBackgroundController.sharedInstance.queue(clipNamed: resString, playOnReady: true)
                    
                } else {
                    DJVideoBackgroundController.sharedInstance.fadeIn(item2String: resString)
                }
                
            }
            
            // if visiting a cell with playback focus
			if DJAudioPlaybackController.sharedInstance.isFocusedOn(item: assocTrackData) {
                if DJAudioPlaybackController.sharedInstance.getAudioPlayerState() == MediaPlayerState.playing {
                    cell.playbackStateBecame(state: .playing)
                    return
                } else if DJAudioPlaybackController.sharedInstance.getAudioPlayerState() != .buffering {
                    cell.playbackStateBecame(state: .suspended)
                }
            } else {  // if visiting cell without AudioPlaybackController focus
                
                cell.playbackStateBecame(state: .suspended)
            }

		}
		
	}
	
	
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		let count = cellDataArr.count
		collectionView.contentSize = CGSize(width: CGFloat(count) * collectionView.frame.width, height: collectionView.frame.height)
		return count
	}
	
	// MARK: - methods
	func handleNoDataAvailable() {
		print("Unable to retrieve any track data.  Manifest is likely empty.")
	}
	
	func absorbTrackData(fromJSON json: JSON) {
		var outList = [CellData]()
		if let trackArr = json.array {
			for track in trackArr {
				let newTrackData = AmbientTrackData(fromJSON: track)
//				print(newTrackData.title ?? "No track title")
				outList.append(newTrackData)
			}
		}
		cellDataArr = outList
		
		collectionView?.reloadData()
	}
	
	func adopt(collectionView: UICollectionView) {
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.register(UINib(nibName: "AmbientTrackCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "TrackCell")
		collectionView.register(UINib(nibName: "SettingsCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SettingsCell")
		collectionView.isPagingEnabled = true
		self.collectionView = collectionView
		
		
//		if cellDataArr.isEmpty {
//			let alertData = CellData.alertCell(withTitle: "No data", color: UIColor.named(.space_beta))
//			cellDataArr = [alertData]
//			collectionView.reloadData()
//		}
	}
	
}
