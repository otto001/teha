//
//  ProjectDetailView.swift
//  teha
//
//  Created by Alexander Baron on 13.01.23.
//

import SwiftUI

struct ProjectDetailView: View {
    let project: THProject
    
    var body: some View {
        Text(project.name ?? "")
    }
}


struct ProjectDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let projects = try! context.fetch(THProject.fetchRequest())
        ProjectDetailView(project: projects.first!)
    }
}
