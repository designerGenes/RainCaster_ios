//
//  enums.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit



enum DJAssetName: String {
	// media player
	case suspended, playing, restart, upwardsArrow, downwardsArrow
	case castButton, castButtonActive, castButtonInactive, castButtonWorking0, castButtonWorking1
    case soundOutput, soundOutputMute // any better name?
	case cycle0, cycle1
	case back
    case hideButton
	case cloud, sync
	// settings cell icon
	case star, face, people
	
	// ambient track types
	case rainCategoryIcon, spaceCategoryIcon, otherCategoryIcon
}
