//
//  ThemedTrackCollectionViewCell.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//
import Foundation
import UIKit

class ThemedTrackData: CellData {
	var hoursDuration: Int?
	var sourceURLString: String?
}

class ThemedTrackCollectionViewCell: UICollectionViewCell, AdoptiveCell {
	// MARK: - outlets
	@IBOutlet weak var trackTitleLabel: UILabel!
	@IBOutlet weak var trackDurationLabel: UILabel!
	@IBOutlet weak var trackPlaybackStructureBar: UIView!
	@IBOutlet weak var playbackPlayPauseButton: UIButton!
	
	@IBAction func clickedPlayPauseButton(_ sender: UIButton) {
	}

	// MARK: - properties
	var data: ThemedTrackData?
	
	// MARK: - AdoptiveCell methods
	func adopt(data: CellData) {
		if let data = data as? ThemedTrackData {
			self.data = data
			trackTitleLabel.text = data.title ?? ""
			trackDurationLabel.text = "\(data.hoursDuration ?? 10)h"
		}
		
	}
	
	// MARK: - methods
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
