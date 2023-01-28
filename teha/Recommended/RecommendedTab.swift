//
//  RecommendedTab.swift
//  teha
//
//  Created by Matteo Ludwig on 27.01.23.
//

import SwiftUI

struct RecommendedTab: View {
    var body: some View {
        NavigationStack {
            
            RecommendedListView()
                
                .navigationDestination(for: THTask.self) { task in
                    TaskDetailView(task: task)
                }
                .navigationTitle("Suggestions")
        }
        .tabItem {
            Label("Suggestions", systemImage: "lightbulb")
        }
    }
}

struct RecommendedTab_Previews: PreviewProvider {
    static var previews: some View {
        RecommendedTab()
    }
}
