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
import MediaPlayer


class MainPlayerViewController: DJViewController {
	// MARK: - outlets
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var settingsButton: UIButton!
	@IBOutlet weak var logoLabel: UILabel! // TMP
	@IBAction func clickedSettingsButton(_ sender: UIButton) { didClickSettingsButton() }
	@IBOutlet weak var navigationContainerView: UIView!
	
	
	// MARK: - properties
    
	private let topRowButtonsYConstant: CGFloat = 24
	private var hiddenControls = [UIView]()
    private var invisibleButtonOverLabel = UIButton()
    
    
    
    var placeHolderCastButton = UIButton()
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

   
    override func viewDidLayoutSubviews() {
        invisibleButtonOverLabel.frame = logoLabel.frame.applying(CGAffineTransform(scaleX: 1.1, y: 1.1))
        invisibleButtonOverLabel.center = logoLabel.center
    }

    
	
	// MARK: - methods
	func setupHiddenControls() {
        let containerView = UIView()
        
        
		let noDataLabel = UILabel()
		noDataLabel.font = UIFont.filsonSoftBold(size: 30)
		noDataLabel.textAlignment = .center
		noDataLabel.lineBreakMode = .byWordWrapping
		noDataLabel.numberOfLines = 0
		noDataLabel.textColor = UIColor.named(.whiteText)
		noDataLabel.text = "Loading..."
		
        let transformAnimation = CABasicAnimation(keyPath: "transform.scale")
        transformAnimation.fromValue = 1
        transformAnimation.toValue = 1.3
        transformAnimation.duration = 0.65
        transformAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transformAnimation.autoreverses = true
        transformAnimation.repeatCount = HUGE
        
        
		let activityIndicatorView = UIActivityIndicatorView()
		activityIndicatorView.activityIndicatorViewStyle = .white
		activityIndicatorView.hidesWhenStopped = true
		activityIndicatorView.stopAnimating()
		
		let retryButtonContainerView = UIView()
		retryButtonContainerView.backgroundColor = UIColor.named(.nearly_black)
		
		let retryButton = UIButton()
		retryButton.setTitle("retry", for: .normal)
		retryButton.titleLabel?.font = UIFont.sfDisplayRegular(size: 24)
		retryButton.setTitleColor(UIColor.named(.whiteText), for: .normal)
		retryButton.addTarget(self, action: #selector(manuallyCheckFeed), for: .touchUpInside)
		
		for hiddenView: UIView in [noDataLabel, retryButtonContainerView, activityIndicatorView, retryButton] {
			view.addSubview(hiddenView)
			hiddenView.translatesAutoresizingMaskIntoConstraints = false
			hiddenView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
			hiddenControls.append(hiddenView)
		}
		
        
        
		noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -16).isActive = true
		noDataLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
		retryButton.centerYAnchor.constraint(equalTo: retryButtonContainerView.centerYAnchor).isActive = true
		retryButtonContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
		retryButtonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		retryButtonContainerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
		
		activityIndicatorView.centerYAnchor.constraint(equalTo:retryButtonContainerView.centerYAnchor).isActive = true
        
        noDataLabel.layer.add(transformAnimation, forKey: "transform.scale")
	}

	
	func setHiddenControlVisibility(to visible: Bool) {
        if visible && hiddenControls.isEmpty {
            setupHiddenControls()
        }
        
		let hiddenActivityIndicator = hiddenControls.filter({$0 is UIActivityIndicatorView}).first as? UIActivityIndicatorView
		
		
		for hiddenControl in hiddenControls {
			hiddenControl.isHidden = !visible
		}
		
		if visible {
			hiddenActivityIndicator?.stopAnimating()
		}
		
		collectionView.isHidden = visible
	}

	func manuallyCheckFeed() {
		let hiddenActivityIndicator = hiddenControls.filter({$0 is UIActivityIndicatorView}).first as? UIActivityIndicatorView
		let retryButton = hiddenControls.filter({$0 is UIButton}).first as? UIButton
		retryButton?.isHidden = true
		hiddenActivityIndicator?.startAnimating()
		
        AppDelegate.shared?.assembleAmbientTrackData(forcePull: true)

	}
	
	func setupCastButton() {
        
        placeHolderCastButton.setImage(UIImage(fromAssetNamed: .castButtonInactive), for: .normal)
        
		let castButton = GCKUICastButton()
		self.castButton = castButton
        
        for button: UIButton in [placeHolderCastButton, castButton] {
        
            view.addSubview(button)
            button.tintColor = UIColor.named(.whiteText)
            button.frame.size = settingsButton.frame.size
            button.translatesAutoresizingMaskIntoConstraints = false
            button.rightAnchor.constraint(equalTo: settingsButton.leftAnchor, constant: -24).isActive = true
            button.centerYAnchor.constraint(equalTo: settingsButton.centerYAnchor).isActive = true
		}
		castButton.setInactiveIcon(UIImage(fromAssetNamed: .castButton), activeIcon: UIImage(fromAssetNamed: .castButtonActive), animationIcons: [
            UIImage(fromAssetNamed: .castButtonWorking0),
            UIImage(fromAssetNamed: .castButtonWorking1),
            UIImage(fromAssetNamed: .castButtonActive),
            UIImage(fromAssetNamed: .castButtonWorking1),
            UIImage(fromAssetNamed: .castButtonWorking0),
            ])
        
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        view.backgroundColor = UIColor.named(.gray_0)
        
		
		dataSource.adopt(collectionView: collectionView)
		collectionView.reloadData()
		GCKCastContext.sharedInstance().sessionManager.add(self)
		setupCastButton()
		navigationContainerView.backgroundColor = UIColor.named(.nearly_black)
		
		
		
        
        let volumeView = MPVolumeView(frame: .zero)
        volumeView.alpha = 0.0001
        view.addSubview(volumeView)
        
        logoLabel.textColor = UIColor.named(.whiteText)
        
        
        invisibleButtonOverLabel.addTarget(self, action: #selector(cycleLogoColor), for: .touchUpInside)
        navigationContainerView.addSubview(invisibleButtonOverLabel)
        
        logoLabel.textColor = UIColor.named(.whiteText)
        
	}
    
    
    
    
    func cycleLogoColor() {
        let colors: [UIColor] = [AmbientTrackCategory.space.associatedColor(), AmbientTrackCategory.rain.associatedColor(), AmbientTrackCategory.other.associatedColor(), UIColor.named(.whiteText)]
        
        
        for z in 0..<colors.count {
            if colors[z] == logoLabel.textColor {
                let nextIdx = colors.count > z + 1 ? z + 1 : 0
                logoLabel.textColor = colors[nextIdx]
                break
            }
            
        }
        
    }
}

