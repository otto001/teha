//
//  SuggestionsTab.swift
//  teha
//
//  Created by Matteo Ludwig on 27.01.23.
//

import SwiftUI

/**
    A struct that implements the `View` protocol to create the Suggestions tab that displays all the task suggestions which the user can complete. Or more precisly when the user should start with the task in order to complete them in time.

    The `body` property returns a `NavigationStack` that contains a `SuggestionsListView`
    as its root view. Tapping on an item in the `SuggestionsListView` navigates to a
    `TaskDetailView` to display the details of a task.
 */
struct SuggestionsTab: View {
    var body: some View {
        NavigationStack {
            
            SuggestionsListView()
                
                .navigationDestination(for: NavigationPage.self) { page in
                    page.view
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
