//
//  AppDelegate.swift
//  BranchPluginExample
//
//  Created by Jimmy Dee on 4/14/17.
//  Copyright © 2017 Branch Metrics. All rights reserved.
//

import Branch
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Branch.getInstance().initSession(launchOptions: launchOptions) {
            universalObject, linkProperties, error in

            // TODO: Route Branch links
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
      return Branch.getInstance().continue(userActivity)
    }

}

