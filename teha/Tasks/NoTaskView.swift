//
//  NoTaskView.swift
//  teha
//
//  Created by Denis Ukehaxhaj on 30.01.23.
//

import SwiftUI

struct NoTaskView: View {
    var body: some View {
        VStack{
            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                .font(.largeTitle)
                .padding(.bottom, 8)
            Text("no-tasks")
                .padding(.bottom, 4)
            Text("no-tasks-empty-text")
                .font(.caption)
                .foregroundColor(.secondaryLabel)
                .padding(.bottom, 4)

        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 30)
    }
}

struct NoTaskView_Previews: PreviewProvider {
    static var previews: some View {
        NoTaskView()
    }
}
