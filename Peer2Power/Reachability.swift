//
//  Reachability.swift
//  Peer2Power
//
//  Created by Deja Jackson on 1/12/23.
//

import Foundation
import Network

class Reachability: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "monitor")
    @Published private(set) var connected = false
    
    func checkConnection() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.connected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    init() {
        checkConnection()
    }
}
