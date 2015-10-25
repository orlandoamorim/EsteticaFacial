//
//  Reachability.swift
//
//  Created by PJ Vea on 10/19/15.
//  Copyright © 2015 Vea Software. All rights reserved.
//
// http://stackoverflow.com/questions/25398664/check-for-internet-connection-availability-in-swift

import Foundation
import SystemConfiguration

struct Platform
{
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
        }()
}

protocol VSReachability
{
    func isConnectedToNetwork() -> Bool
}

extension VSReachability
{
    func isConnectedToNetwork() -> Bool
    {
        if Platform.isSimulator
        {
            print("NOTE: Simulator alwasy returns true.")
            return true
        }
        else
        {
            var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
            zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)

            let defaultRouteReachability = withUnsafePointer(&zeroAddress)
                {
                    SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
            }

            var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
            if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false
            {
                return false
            }

            let isReachable = flags == .Reachable
            let needsConnection = flags == .ConnectionRequired

            return isReachable && !needsConnection
        }
    }
}
