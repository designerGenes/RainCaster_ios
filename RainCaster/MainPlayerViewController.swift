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


class MainPlayerViewController: DJViewController {
	// MARK: - outlets
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var settingsButton: UIButton!
	@IBOutlet weak var logoLabel: UILabel! // TMP
	@IBAction func clickedSettingsButton(_ sender: UIButton) { didClickSettingsButton() }
	@IBOutlet weak var navigationContainerView: UIView!
	
	
	// MARK: - properties
	private let topRowButtonsYConstant: CGFloat = 24
	var castButton: GCKUICastButton?
	let dataSource = AmbientTrackDataSource.sharedInstance
	var manager: GCKDeviceManager?
	var miniMediaControlsContainerView = UIView()
	var miniControlVC: GCKUIMiniMediaControlsViewController?

	func didClickSettingsButton() {
		if let settingsVC = Bundle.main.loadNibNamed("SettingsViewController", owner: self, options: nil)?.first as? SettingsViewController {
			present(settingsVC, animated: true, completion: nil)
		}
	}
	
	func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
		print("GCK Cast session will start")
	}

	
	// MARK: - methods

	func setupCastButton() {
		let castButton = GCKUICastButton()
		self.castButton = castButton
		view.addSubview(castButton)
		castButton.tintColor = UIColor.named(.whiteText)
		castButton.frame.size = settingsButton.frame.size
		castButton.translatesAutoresizingMaskIntoConstraints = false
		castButton.rightAnchor.constraint(equalTo: settingsButton.leftAnchor, constant: -24).isActive = true
		castButton.centerYAnchor.constraint(equalTo: settingsButton.centerYAnchor).isActive = true
		
		castButton.setInactiveIcon(UIImage(fromAssetNamed: .castButton), activeIcon: UIImage(fromAssetNamed: .castButtonActive), animationIcons: [UIImage(fromAssetNamed: .castButton), UIImage(fromAssetNamed: .castButtonActive)])
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		dataSource.adopt(collectionView: collectionView)
		collectionView.reloadData()
		GCKCastContext.sharedInstance().sessionManager.add(self)
		setupCastButton()
		navigationContainerView.backgroundColor = UIColor.named(.nearly_black)
	}
}

