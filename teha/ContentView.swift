//
//  ContentView.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {

        TabView {
            ProjectsTab()
            TasksTab()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
