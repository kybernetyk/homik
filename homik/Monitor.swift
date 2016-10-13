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

//the monitor is the meat of the application. it handles concurrent server checking
//and report generation
class Monitor {
    fileprivate var services: [ServiceDescription] = []
    
    fileprivate var networkQueue = DispatchQueue(label: "Monitor.Network", attributes: .concurrent)
    fileprivate var networkGroup = DispatchGroup()
    
    fileprivate var serviceAccessQueue = DispatchQueue(label: "Monitor.Update")
    fileprivate var honkqueue = DispatchQueue(label: "Monitor.Update")
    
    
    fileprivate var stats: [ServiceDescription : StatusReport.Status] = [:]
}

//MARK: - public iface
extension Monitor {
    //add a service to the watchlist
    func addService(service: ServiceDescription) {
        self.serviceAccessQueue.sync {
            self.services.append(service)
            self.stats[service] = .Broken
        }
    }
    
    //start the endless update loop loop
    func start() {
        self.honkqueue.async {
            self.loop()
        }
    }
    
    //thread safe getter for the reports
    public var reports: [StatusReport] {
        get {
            let watchlist = self.serviceAccessQueue.sync {
                return self.stats
            }
            
            var reports: [StatusReport] = []
            for service in watchlist {
                let rep = StatusReport(service: service.key, status: service.value)
                reports.append(rep)
            }
            return reports
        }
    }

}

//MARK: - work scheduling
extension Monitor {
    //loops endlessly and checks each watched service every N seconds
    //the status is then saved into `self.stats` which can be accessed
    //by the user via the `self.reports` property
    fileprivate func loop() {
        while true {
            let watchlist = self.serviceAccessQueue.sync {
                return self.services
            }
            
            //for every service we're watching fire a concurrent work item...
            for service in watchlist {
                self.networkQueue.async(group: self.networkGroup) {
                    
                    let result = self.httpConnect(url: service.endpoint)
                    self.serviceAccessQueue.sync {
                        self.stats[service] = result ? .OK : .Broken
                    }
                    
                }
            }
            
            //wait till all services have been checked
            self.networkGroup.wait()
            
            //now sleep for 5 seconds till we can perform the next check...
            sleep(5)
        }
    }
    
}

//MARK: - http
extension Monitor {
    fileprivate func httpConnect(url: String) -> Bool {
        if let url = URL(string: url) {
            let result = try? NSString(contentsOf: url, encoding: String.Encoding.utf8.rawValue)
            return result != nil
        }
        return false
    }
}
