//
//  SuggestionsTab.swift
//  teha
//
//  Created by Matteo Ludwig on 27.01.23.
//

import SwiftUI

struct SuggestionsTab: View {
    var body: some View {
        NavigationStack {
            
            SuggestionsListView()
                
                .navigationDestination(for: THTask.self) { task in
                    TaskDetailView(task: task)
                }
                .navigationTitle(LocalizedStringKey("suggestions"))
        }
        .tabItem {
            Label(LocalizedStringKey("suggestions"), systemImage: "lightbulb")
        }
    }
}

struct SuggestionsTab_Previews: PreviewProvider {
    static var previews: some View {
        SuggestionsTab()
    }
}
