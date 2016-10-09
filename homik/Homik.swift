//
//  Homik.swift
//  The main interface to Homik
//
//  Created by kyb on 09/10/2016.
//  Copyright © 2016 Suborbital Softowrks Ltd. All rights reserved.
//

import Foundation

class Homik {
    fileprivate var monitor = Monitor()
    
    var reports: [StatusReport] {
        get {
            return monitor.reports
        }
    }
    
    func update() {
        self.monitor.run()
    }
}

extension Homik {
    public func monitorWebsite(url: String) {
        let srv = ServiceDescription(endpoint: url, type: .HTTPGET)
        monitor.addService(service: srv)
    }    
}
