//
//  SettingsViewController.swift
//  RainCaster
//
//  Created by Jaden Nation on 7/25/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit
import MessageUI



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

class SettingsViewController: DJViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
	// MARK: - outlets
	@IBOutlet weak var settingsTableView: UITableView!
	@IBOutlet weak var exitButton: UIButton!
	@IBAction func tappedExitButton(_ sender: UIButton) { tappedExitButton()}

	
	// MARK: - properties
	let items: [SettingsItem] = [SettingsItem.feedback, .aboutUs, .share]
	private let cellSpacingHeight: CGFloat = 32
	
    // MARK: - MFMailComposeViewControllerDelegate methods
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
	
	// MARK: - methods 
	func tappedExitButton() {
		dismiss(animated: true, completion: nil)
	}
	
	
	// MARK: - UITableViewDelegate methods
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
		switch items[indexPath.section] {
            
		case .feedback:
            let mailVC = MFMailComposeViewController()
            mailVC.setSubject("Raincstr Feedback")
            mailVC.setToRecipients([ AppDelegate.shared?.contactAddress ?? "jnationdesignerjeans@gmail.com"])
            mailVC.setMessageBody("Hi!  Here's what I thought about Raincstr: <br>", isHTML: true)
            mailVC.mailComposeDelegate = self
            present(mailVC, animated: true, completion: nil)
		case .aboutUs:
            let alertController = UIAlertController(title: "About Us", message: "Raincstr is (c) 2017 by Jaden Nation", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
		case .share:
            let activityViewController = UIActivityViewController(activityItems: ["Check out Raincstr on the App Store!"], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
            
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
