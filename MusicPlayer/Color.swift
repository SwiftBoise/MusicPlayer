//
//  MusicPlayer
//
//  Copyright © 2018 Swift Boise. All rights reserved.
//

import UIKit

public struct Color {

    private static let colors = Bundle.main.object(forInfoDictionaryKey: "SBColor" as String) as! NSDictionary

    public struct Primary {

        private static let color = colors["Primary"] as! [NSNumber]
        private static let red = CGFloat(color[0].floatValue)
        private static let green = CGFloat(color[1].floatValue)
        private static let blue = CGFloat(color[2].floatValue)

        public static var regular: UIColor {
            return UIColor(red: red, green: green, blue: blue)
        }

        public static var light: UIColor {
            return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 0.1)
        }

    }

}
