//
//  DebugController.swift
//  RainCaster
//
//  Created by Jaden Nation on 8/6/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit

enum InvolvedViewControllerName: String {
	case mainPlayer, settings
}

class DebugController: NSObject {
	static func jumpTo(viewControllerWith name: InvolvedViewControllerName, after delay: Double = 0) {
		DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
			
		}
		
		
	}
	
}
