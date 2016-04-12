//
//  UserDefaultsPasscodeRepository.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 11/04/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import Foundation
import PasscodeLock

class UserDefaultsPasscodeRepository: PasscodeRepositoryType {
    
    private let passcodeKey = "passcode.lock.passcode"
    
    private lazy var defaults: NSUserDefaults = {
        
        return NSUserDefaults.standardUserDefaults()
    }()
    
    var hasPasscode: Bool {
        
        if passcode != nil {
            return true
        }
        
        return false
    }
    
    var passcode: [String]? {
        
        return defaults.valueForKey(passcodeKey) as? [String] ?? nil
    }
    
    func savePasscode(passcode: [String]) {
        
        defaults.setObject(passcode, forKey: passcodeKey)
        defaults.synchronize()
    }
    
    func deletePasscode() {
        
        defaults.removeObjectForKey(passcodeKey)
        defaults.synchronize()
    }
}
