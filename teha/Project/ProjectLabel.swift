//
//  ProjectLabel.swift
//  teha
//
//  Created by Matteo Ludwig on 13.01.23.
//

import SwiftUI

/// A view that displays a project's name and color.
struct ProjectLabel: View {
    @ObservedObject var project: THProject
    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundStyle(project.color.color, .gray)
            Text(project.name ?? "")
        }
    }
}

struct ProjectLabel_Previews: PreviewProvider {
    static var project: THProject {
        let project = try! PersistenceController.preview.container.viewContext.fetch(THProject.all).first!
        
        return project
    }
    static var previews: some View {
        ProjectLabel(project: project)
    }
}
