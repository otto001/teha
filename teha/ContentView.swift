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

    @State var color: ColorChoice = .pink
    var body: some View {

        TabView {
            ProjectsList()
            .tabItem {
                Label("Projects", systemImage: "briefcase")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
