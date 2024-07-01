//
//  TimeLogTab.swift
//  teha
//
//  Created by Matteo Ludwig on 01.07.24.
//

import SwiftUI

struct TimeLogTab: View {
    var body: some View {
        NavigationStack {
            TimeLogEntryListView()
                .navigationTitle("Time Log")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: NavigationPage.self) { page in
                    page.view
                }
        }.tabItem { Label("Time Log", systemImage: "clock.badge.checkmark.fill") }
    }
}

#Preview {
    TimeLogTab()
}
