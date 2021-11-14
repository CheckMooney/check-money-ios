//
//  SideMenuNavigation.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/11/13.
//

import Foundation
import SideMenu

class SideMenuOption: SideMenuNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presentationStyle = .menuSlideIn
        self.presentationStyle.presentingEndAlpha = 0.7
    }
}
