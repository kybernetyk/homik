//
//  Homik.swift
//  The main interface to Homik
//
//  Created by kyb on 09/10/2016.
//  Copyright © 2016 Suborbital Softowrks Ltd. All rights reserved.
//

import Foundation

//this is the front end interface to the end user
//currently the user has poll homik every N seconds for
//updates.
//but we're going to fire update events in the future...
class Homik {
    fileprivate var monitor = Monitor()
    
    //get the newest homik reports
    var reports: [StatusReport] {
        get {
            return monitor.reports
        }
    }
    
    //start homik monitoring
    func start() {
        self.monitor.start()
    }
}

//proxy methods
extension Homik {
    public func monitorWebsite(url: String) {
        let srv = ServiceDescription(endpoint: url, type: .HTTPGET)
        monitor.addService(service: srv)
    }
}
