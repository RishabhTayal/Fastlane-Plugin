//
//  Fastlane.m
//  Fastlane
//
//  Created by Tayal, Rishabh on 2/18/16.
//  Copyright © 2016 Tayal, Rishabh. All rights reserved.
//

import Foundation
import AppKit

class Fastlane: NSObject {
    
    var bundle: NSBundle!
    
    var fastlaneMenuItem: NSMenuItem!
    var addEditFastlaneMenuItem: NSMenuItem!
    var runFastlaneMenuItem: NSMenuItem!
    
    var lanesWindow: LanesWindow!
    
    static var sharedPlugin: Fastlane!
    
    init(plugin: NSBundle) {
        // reference to plugin's bundle, for resource access
        super.init()
        self.bundle = plugin;
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didApplicationFinishLaunchingNotification:", name: NSApplicationDidFinishLaunchingNotification, object: nil)
    }
    
    func didApplicationFinishLaunchingNotification(noti: NSNotification) {
        //removeObserver
        NSNotificationCenter.defaultCenter().removeObserver(self, name:NSApplicationDidFinishLaunchingNotification, object:nil)
        
        // Create menu items, initialize UI, etc.
        if let topMenuItem = NSApp.mainMenu?.itemWithTitle("Product") {
            
            topMenuItem.submenu?.addItem(NSMenuItem.separatorItem())
            
            fastlaneMenuItem = NSMenuItem(title: "Fastlane", action: nil, keyEquivalent: "")
            fastlaneMenuItem.target = self
            self.fastlaneMenuItem.submenu = NSMenu(title: "Fastlane")
            
            self.addEditFastlaneMenuItem = NSMenuItem(title: "Add/Edit Fastfile", action: "editFastfile", keyEquivalent: "")
            self.addEditFastlaneMenuItem.target = self
            self.addEditFastlaneMenuItem.keyEquivalentModifierMask =  Int(NSEventModifierFlags.ControlKeyMask.rawValue | NSEventModifierFlags.AlternateKeyMask.rawValue | NSEventModifierFlags.CommandKeyMask.rawValue)
            self.addEditFastlaneMenuItem.keyEquivalent = "e"
            fastlaneMenuItem.submenu!.addItem(self.addEditFastlaneMenuItem)
            
            self.runFastlaneMenuItem = NSMenuItem(title: "Run Fastlane 🚀", action: "runFastlane", keyEquivalent: "")
            self.runFastlaneMenuItem.target = self
            self.runFastlaneMenuItem.keyEquivalentModifierMask = Int(NSEventModifierFlags.ControlKeyMask.rawValue | NSEventModifierFlags.AlternateKeyMask.rawValue | NSEventModifierFlags.CommandKeyMask.rawValue)
            self.runFastlaneMenuItem.keyEquivalent = "f"
            fastlaneMenuItem.submenu!.addItem(self.runFastlaneMenuItem)
            
            fastlaneMenuItem.submenu!.addItem(NSMenuItem.separatorItem())
            
            let setupFastlane: NSMenuItem = NSMenuItem(title: "Setup Fastlane", action: "setupFastlane", keyEquivalent: "")
            setupFastlane.target = self
            fastlaneMenuItem.submenu!.addItem(setupFastlane)
            
            topMenuItem.submenu!.insertItem(fastlaneMenuItem, atIndex: topMenuItem.submenu!.indexOfItemWithTitle("Build For"))
        }
    }
    
    func editFastfile() {
        NSLog("add lane")
        let project: FLProject = FLProject.projectForKeyWindow()
        let fastfilePath: String = project.fastfilePath
        if !project.hasFastfile() {
            return
        }
        NSApplication.sharedApplication().delegate!.application!(NSApplication.sharedApplication(), openFile: fastfilePath)
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        NSLog("validating")
        if menuItem.isEqual(self.addEditFastlaneMenuItem) || menuItem.isEqual(self.runFastlaneMenuItem) {
            NSLog("%@", FLWorkspaceManager.currentWorkspaceDirectoryPath())
            if FLProject.projectForKeyWindow().hasFastfile() {
                return true
            }
            else {
                return false
            }
        }
        return true
    }
    
    func runFastlane() {
        let shellRunner: FLShellRunner = FLShellRunner()
        //    NSString* path = [NSString stringWithFormat:@"%@/Desktop/Personal/fastlane/bin/fastlane", NSHomeDirectory()];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() -> Void in
            let data: NSData = shellRunner.runScriptPath(FLProject.projectForKeyWindow().fastlanePath(), arguments: ["lanes", "--json"], withDirectoryPath: FLWorkspaceManager.currentWorkspaceDirectoryPath())
            let string: String = String(data: data, encoding: NSUTF8StringEncoding)!
            
            string.enumerateSubstringsInRange(string.startIndex..<string.endIndex, options: NSStringEnumerationOptions.ByWords, { (substring, substringRange, enclosingRange, stop) -> () in
                
            })
            
            let jsonString = string.substringFromIndex((string.rangeOfString("{")?.startIndex)!)
            do {
                let lanesJson = try NSJSONSerialization.JSONObjectWithData(jsonString.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments)
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    self.lanesWindow = LanesWindow()
                    self.lanesWindow.lanesData = lanesJson as! Dictionary<String, Dictionary<String, Dictionary<String, AnyObject>>>
                    self.lanesWindow.workspacePath = FLWorkspaceManager.currentWorkspaceDirectoryPath()
                    NSApp.keyWindow!.beginSheet(self.lanesWindow.window!, completionHandler: nil)
                })
            } catch {
                
            }
        })
    }
    
    func setupFastlane() {
        let runner: FLShellRunner = FLShellRunner()
        let runningApps = NSWorkspace.sharedWorkspace().runningApplications
        for app: NSRunningApplication in runningApps {
            if (app.bundleIdentifier!.lowercaseString == "com.apple.terminal") {
                app.activateWithOptions(NSApplicationActivationOptions.ActivateAllWindows.union(NSApplicationActivationOptions.ActivateIgnoringOtherApps))
            }
        }
        runner.runScriptPath("/usr/bin/osascript", arguments: ["-e", "tell app \"Terminal\" \n do script activate \n delay 1 \n do script \"cd \(FLWorkspaceManager.currentWorkspaceDirectoryPath())\" in window 1 \ndo script \"fastlane init\" in window 1\n end tell"], withDirectoryPath: FLWorkspaceManager.currentWorkspaceDirectoryPath()) { (data: NSData!) -> Void in
            
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension NSObject {
    class func pluginDidLoad(plugin: NSBundle)
    {
        let currentApplicationName = NSBundle.mainBundle().infoDictionary!["CFBundleName"]
        if ((currentApplicationName?.isEqual("Xcode")) != nil) {
            Fastlane.sharedPlugin = Fastlane(plugin: plugin)
        }
    }
}