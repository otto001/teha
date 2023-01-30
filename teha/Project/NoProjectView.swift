//
//  NoProjectView.swift
//  teha
//
//  Created by Denis Ukehaxhaj on 30.01.23.
//

import SwiftUI


/// A view that shows when no projects have been created yet.
struct NoProjectView: View {
    var body: some View { 
        VStack{
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.largeTitle)
                .padding(.bottom, 8)
            Text("no-projects")
                .padding(.bottom, 4)
            Text("no-projects-empty-text")
                .font(.caption)
                .foregroundColor(.secondaryLabel)
                .padding(.bottom, 4)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 30)
    }
}

struct noProjectView_Previews: PreviewProvider {
    static var previews: some View {
        NoProjectView()
    }
}
