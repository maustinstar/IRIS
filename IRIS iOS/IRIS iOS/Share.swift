//
//  Share.swift
//  IRIS iOS
//
//  Created by Michael Verges on 11/7/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import UIKit

extension UIApplication {
    
    class var current: UIViewController? {
        return getCurrentViewController()
    }
    
    private class func getCurrentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getCurrentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getCurrentViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getCurrentViewController(base: presented)
        }
        return base
    }
}

extension Equatable {
    func share() {
        let activity = UIActivityViewController(activityItems: [self], applicationActivities: nil)
        UIApplication.current?.present(activity, animated: true, completion: nil)
    }
}
