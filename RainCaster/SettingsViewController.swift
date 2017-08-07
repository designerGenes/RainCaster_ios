//
//  SettingsViewController.swift
//  RainCaster
//
//  Created by Jaden Nation on 7/25/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit

enum SettingsItem: String {
	case feedback, share
	case aboutUs = "about us"
	func assocIcon() -> UIImage {
		switch self {
		case .feedback: return UIImage(fromAssetNamed: .star)
		case .aboutUs: return UIImage(fromAssetNamed: .face)
		case .share: return UIImage(fromAssetNamed: .people)
		}
	}
	
	
}

class SettingsViewController: DJViewController, UITableViewDelegate, UITableViewDataSource {
	// MARK: - outlets
	@IBOutlet weak var settingsTableView: UITableView!
	@IBOutlet weak var exitButton: UIButton!
	@IBAction func tappedExitButton(_ sender: UIButton) { tappedExitButton()}

	
	// MARK: - properties
	let items: [SettingsItem] = [SettingsItem.feedback, .aboutUs, .share]
	private let cellSpacingHeight: CGFloat = 32
	
	
	// MARK: - methods 
	func tappedExitButton() {
		dismiss(animated: true, completion: nil)
	}
	
	
	// MARK: - UITableViewDelegate methods
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch items[indexPath.row] {
		case .feedback: break
		case .aboutUs: break
		case .share: break
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return cellSpacingHeight * 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	
	
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return items.count
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return cellSpacingHeight
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: cellSpacingHeight)))
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellColors: [UIColor] = [UIColor.named(.space_red), UIColor.named(.rain_blue), UIColor.named(.gray_1)]
		if let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as? SettingsTableViewCell {
			cell.adopt(settingsItem: items[indexPath.section])
			cell.addBubble(withColor: cellColors[indexPath.section])
//			cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? UIColor(hexString: "#262626") : UIColor(hexString: "#262626").lightenBy(percent: 0.25)
			
			return cell
		}
		
		return UITableViewCell()
	}
	
	
	
	// MARK: - lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
		settingsTableView.dataSource = self
		settingsTableView.delegate = self
		settingsTableView.register(UINib(nibName: "SettingsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "settingsCell")
		settingsTableView.separatorStyle = .none
		settingsTableView.backgroundColor = view.backgroundColor
		
		
		
    }
}
