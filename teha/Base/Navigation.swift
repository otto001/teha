//
//  Navigation.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import SwiftUI

class Router: ObservableObject {
    @Published var path = NavigationPath()
    
    func pop(_ n: Int = 1) {
        self.path.removeLast(n)
    }
}


struct RoutedNavigation<Root: View>: View {
    @ViewBuilder let root: () -> Root
    @StateObject var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            root().environmentObject(router)
        }
    }
}

struct Navigation_Previews: PreviewProvider {
    static var previews: some View {
        RoutedNavigation {
            Text("Hey")
        }
    }
}
