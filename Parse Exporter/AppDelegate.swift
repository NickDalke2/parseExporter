//
//  AppDelegate.swift
//  Parse Exporter
//
//  Created by Nick Dalke on 1/12/17.
//  Copyright © 2017 Nick Dalke. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        Parse.initialize(with: ParseClientConfiguration(block: { (parseClientConfiguration) in
            parseClientConfiguration.applicationId = "CFjrpUbTIMWIa3HGPX3329dcG2ouX5pjEGbTOFLI"
            parseClientConfiguration.clientKey = "PDYvn7DGbvIa3PpOiVbOwg321YXeQ3Z9t4MIYT9T"
            parseClientConfiguration.server = "https://parseapi.back4app.com"
        }))
        //
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

