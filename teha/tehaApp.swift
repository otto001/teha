//
//  tehaApp.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import SwiftUI

@main
struct tehaApp: App {
    let persistenceController = PersistenceController.shared
    let geo:GeoMonitor
    
    init(){
        geo = GeoMonitor()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
