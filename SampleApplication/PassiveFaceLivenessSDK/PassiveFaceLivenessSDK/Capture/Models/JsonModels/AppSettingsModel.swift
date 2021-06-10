/*
 *  © 2017-2019 Aware, Inc.  All Rights Reserved.
 *
 *  NOTICE:  All information contained herein is, and remains the property of Aware, Inc.
 *  and its suppliers, if any.  The intellectual and technical concepts contained herein
 *  are proprietary to Aware, Inc. and its suppliers and may be covered by U.S. and
 *  Foreign Patents, patents in process, and are protected by trade secret or copyright law.
 *  Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Aware, Inc.
 */

import AVFoundation
import os.log


public class AppSettingsModel: NSObject, NSCoding {
    
    // NOTE: Persist data ref: https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/PersistData.html
    
    //
    // MARK: Properties
    //
    
    private let defaultKnomiServerEndpoint = "http://mobileauth.aware-demos.com:8084/knomi"
    
    public var captureTimeout: Int
    public var username: String
    public var serverUrl: String
    public var workflow: String
    public var displayMode: String


    //
    // MARK: Archiving Paths
    //
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("ClientServerSettings")
    
    
    //
    // MARK: Types
    // 
    
    struct PropertyKey {
        static let captureTimeoutKey = "captureTimeout"
        static let usernameKey = "username"
        static let serverUrlKey = "serverUrl"
        static let workflowKey = "workflow"
        static let displayModeKey = "displayMode"
    }

    
    //
    // MARK: Initializer(s)
    //
    
    // Default initializer
    override init() {
       
        self.captureTimeout = 0
        self.username = "--- Enter username ---"
        self.serverUrl = defaultKnomiServerEndpoint
        self.workflow = "alfa"
        self.displayMode = DisplayMode.standard.rawValue
    }
    
    public init?(
        captureTimeout: Int,
        username: String,
        serverUrl: String,
        workflow: String,
        displayMode: String
        ) {
        
        self.captureTimeout = captureTimeout
        self.username = username.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.serverUrl = serverUrl
        self.workflow = workflow
        self.displayMode = displayMode
    }
    
    public init(settings: AppSettingsModel) {

        self.captureTimeout = settings.captureTimeout
        self.username = settings.username
        self.serverUrl = settings.serverUrl
        self.workflow = settings.workflow
        self.displayMode = settings.displayMode
    }
    
    public init?(
        captureTimeout: Int,
        serverUrl: String,
        workflow: String,
        displayMode: String
        ) {
        
        self.captureTimeout = captureTimeout
        self.username = ""
        self.serverUrl = serverUrl
        self.workflow = workflow
        self.displayMode = displayMode
    }
    //
    // MARK: NSCoding
    //
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(captureTimeout, forKey: PropertyKey.captureTimeoutKey)
        aCoder.encode(username, forKey: PropertyKey.usernameKey)
        aCoder.encode(serverUrl, forKey: PropertyKey.serverUrlKey)
        aCoder.encode(workflow, forKey: PropertyKey.workflowKey)
        aCoder.encode(displayMode, forKey: PropertyKey.displayModeKey)
    }
    
    // Secondary initializer (convenience) required as subclass of NSCoding 
    // since the subclass defines its own initializers. If a required property cannot 
    // be decoded, the initializer will fail and return nil.
    required convenience public init?(coder aDecoder: NSCoder) {
        
        let captureT = aDecoder.decodeInteger(forKey: PropertyKey.captureTimeoutKey)
        
        // Use guard let for required properties, use let for optional properties
        guard let username = aDecoder.decodeObject(forKey: PropertyKey.usernameKey) as? String else {

            return nil
        }
        
        guard let serverUrl = aDecoder.decodeObject(forKey: PropertyKey.serverUrlKey) as? String else {

            return nil
        }
        
        guard let workflow = aDecoder.decodeObject(forKey: PropertyKey.workflowKey) as? String else {
            
            return nil
        }
        
        guard let displayMode = aDecoder.decodeObject(forKey: PropertyKey.displayModeKey) as? String else {
            
            return nil
        }

        // Must call designated initializer
        self.init(captureTimeout: captureT,
                  username: username,
                  serverUrl: serverUrl,
                  workflow: workflow,
                  displayMode: displayMode)
    }
    
    // Validation Methods
    public func isUsernameOK() -> Bool {
        if username == "" {
            return false
        }
        
        return true
    }
    
    private func toString() -> String {
        
        let message =
            "captureTimeout: \(captureTimeout) \n" +
                "username: " + username + "\n" +
                "serverUrl: " + serverUrl + "\n" +
                // "workflow: " + workflow + "\n" +
                // "camera: \(camera) \n" +
                "displayMode: " + displayMode
        
        return message
    }
    
    override public var description: String {
        get {
            return toString()
        }
    }
    
}
