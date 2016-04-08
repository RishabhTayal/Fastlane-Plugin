//
//  LanesWindow.m
//  Fastlane
//
//  Created by Tayal, Rishabh on 2/22/16.
//  Copyright © 2016 Tayal, Rishabh. All rights reserved.
//

import Cocoa

class LanesWindow: NSWindowController {
    
    @IBOutlet var popUpButton1: NSPopUpButton!
    @IBOutlet var popUpButton2: NSPopUpButton!
    @IBOutlet var popUpButton3: NSPopUpButton!
    @IBOutlet var laneDescTextField: NSTextField!
    @IBOutlet var fastlaneButton: NSButton!
    
    var lanesData: Dictionary<String, Dictionary<String, Dictionary<String, AnyObject>>>!
    var workspacePath: String!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.popUpButton1.target = self
        self.popUpButton2.target = self
        self.popUpButton1.autoenablesItems = false
        self.popUpButton1.removeAllItems()
        self.popUpButton2.removeAllItems()
        self.popUpButton1.addItemsWithTitles([String](lanesData.keys))
        self.popup1Changed(self.popUpButton1)
        self.fastlaneButton.target = self
        self.fastlaneButton.action = "runFastlane:"
        self.loadEnvironments()
    }
    
    @IBAction func runFastlane(sender: NSButton) {
        let apps = NSWorkspace.sharedWorkspace().runningApplications
        for app: NSRunningApplication in apps {
            if (app.bundleIdentifier!.lowercaseString == "com.apple.terminal") {
                app.activateWithOptions(NSApplicationActivationOptions.ActivateAllWindows.union(NSApplicationActivationOptions.ActivateIgnoringOtherApps))
            }
        }
        var script: String = "tell app \"Terminal\" \n do script activate \n delay 1 \n do script \"cd \(workspacePath)\" in window 1 \n do script \"fastlane \(self.popUpButton1.titleOfSelectedItem) \(self.popUpButton2.titleOfSelectedItem)"
        if self.popUpButton3.titleOfSelectedItem?.characters.count > 0 {
            script = script.stringByAppendingString(" --env \(self.popUpButton3.titleOfSelectedItem)")
        }
        script = script.stringByAppendingString("\" in window 1 \n end tell")
        let runner: FLShellRunner = FLShellRunner()
        runner.runScriptPath("/usr/bin/osascript", arguments: ["-e", script], withDirectoryPath: workspacePath) { (data: NSData!) -> Void in
            
        }
    }
    
    @IBAction func popup1Changed(sender: AnyObject) {
        let selectedType: String = self.popUpButton1.titleOfSelectedItem!
        let lanes = lanesData[selectedType]
        self.popUpButton2.removeAllItems()
        for lane in (lanes?.keys)! {
            self.popUpButton2.addItemWithTitle(lane )
        }
        self.popup2Changed(self.popUpButton2)
    }
    
    @IBAction func popup2Changed(sender: AnyObject) {
        let selectedPlatform: String = self.popUpButton1.titleOfSelectedItem!
        let lanes = lanesData[selectedPlatform]
        for lane in lanes!.keys {
            if lane == self.popUpButton2.titleOfSelectedItem! {
                let selectedLane: [String: AnyObject] = lanes![lane]!
                self.laneDescTextField.stringValue = selectedLane["description"] as! String
                return
            }
        }
    }
    
    func loadEnvironments() {
        do {
            let dirFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath("\(workspacePath)/fastlane")
            NSLog("%@", dirFiles)
            let envFiles = dirFiles.filter({ (object: String) -> Bool in
                if object.containsString(".env") {
                    return true
                }
                return false
            })
            NSLog("%@", envFiles)
            var enviornments: [String] = []
            for env: String in envFiles {
                let range = env.rangeOfString(".env.")
                enviornments.append(env.stringByReplacingCharactersInRange(range!, withString: ""))
            }
            self.popUpButton3.removeAllItems()
            self.popUpButton3.addItemsWithTitles(enviornments)
        } catch {
            
        }
    }
}
