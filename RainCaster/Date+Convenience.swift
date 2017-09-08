//
//  Date+Convenience.swift
//  RainCaster
//
//  Created by Jaden Nation on 9/4/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit


extension Date {
    static func fromString(str: String) -> Date? {
        
        var strComponents = str.components(separatedBy: ".")
        
        for (z, component) in strComponents.enumerated() {
            if component.characters.count < 2 {
                let replacementString = "0\(component)"
                strComponents.remove(at: z)
                strComponents.insert(replacementString, at: z)
            }
        }
        
        let cleanString = strComponents.joined(separator: "-")
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.dateStyle = .short

        return formatter.date(from: cleanString)
    }
}
