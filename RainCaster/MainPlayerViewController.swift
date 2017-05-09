//
//  MainPlayerViewController.swift
//  RainCaster
//
//  Created by Jaden Nation on 4/22/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit
import GoogleCast
import AVKit
import AVFoundation


class MainPlayerViewController: UIViewController {
	// MARK: - outlets
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var systemMsgLabel: UILabel!
	
	
	// MARK: - properties
	var castButton: GCKUICastButton?
	var dataSource: TrackListCollectionViewDataSource?
	var manager: GCKDeviceManager?
	


	func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
		print("GCK Cast session will start")
	}
	
	// MARK: - methods

	func setupCastButton() {
		let castButton = GCKUICastButton()
		self.castButton = castButton
		view.addSubview(castButton)
		castButton.tintColor = .white
		castButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
		castButton.translatesAutoresizingMaskIntoConstraints = false
		castButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24).isActive = true
		castButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		dataSource = TrackListCollectionViewDataSource()
		dataSource?.adopt(collectionView: collectionView)
		collectionView.reloadData()
		GCKCastContext.sharedInstance().sessionManager.add(self)
		setupCastButton()
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
	}
	
}

