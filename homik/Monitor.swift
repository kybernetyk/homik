//
//  Monitor.swift
//  homik
//
//  Created by kyb on 09/10/2016.
//  Copyright © 2016 Suborbital Softowrks Ltd. All rights reserved.
//

import Foundation
import Dispatch

struct StatusReport {
    enum Status {
        case OK
        case Broken
    }
    
    var service: ServiceDescription
    var status: Status
}

struct ServiceDescription : Hashable {
    enum ServiceType {
        case HTTPGET
    }
    
    var endpoint: String
    var type: ServiceType
    
    var hashValue: Int {
        get {
            return self.endpoint.lowercased().hashValue
        }
    }
}

//MARK: Equatable
func ==(lh: ServiceDescription, rh: ServiceDescription) -> Bool {
    return lh.endpoint.lowercased() == rh.endpoint.lowercased()
}

class Monitor {
    fileprivate var services: [ServiceDescription] = []
    fileprivate var networkQueue = DispatchQueue(label: "Monitor.Network", attributes: .concurrent)
    fileprivate var updateQueue = DispatchQueue(label: "Monitor.Update")
    
    fileprivate var stats: [ServiceDescription : StatusReport.Status] = [:]
    
    func addService(service: ServiceDescription) {
        updateQueue.sync {
            self.services.append(service)
            self.stats[service] = .Broken
        }
    }
    
    //starts the async loop in a bg queue
    //if there's news regarding the endpoints
    //the reports array will be updated (mutex)
    //we won't fire an event for now
    //so the user has to poll us
    //but firing event signals, etc is a possibility in the future
    func run() {
        let ss = updateQueue.sync {
            return self.services
        }

        for s in ss {
            if let url = URL(string: s.endpoint) {
                if let result = try? NSString(contentsOf: url, encoding: String.Encoding.utf8.rawValue) {
                    updateQueue.sync {
                        self.stats[s] = .OK
                    }
                } else {
                    updateQueue.sync {
                        self.stats[s] = .Broken
                    }
                }
            }
        }
    }
    
    var reports: [StatusReport] {
        get {
            let ss = updateQueue.sync {
                return self.stats
            }
            
            var reports: [StatusReport] = []
            for s in ss {
                let rep = StatusReport(service: s.key, status: s.value)
                reports.append(rep)
            }
            return reports
        }
    }
}
