//
//  NoTaskView.swift
//  teha
//
//  Created by Denis Ukehaxhaj on 30.01.23.
//

import SwiftUI

/// displayed text, if no tasks are available due to active filters
struct NoTaskFilterView: View {
    var body: some View {
        VStack{
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.largeTitle)
                .padding(.bottom, 8)
            Text("no-tasks-filter")
                .padding(.bottom, 4)
        
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 30)
    }
}

struct NoTaskFilterView_Previews: PreviewProvider {
    static var previews: some View {
        NoTaskFilterView()
    }
}
