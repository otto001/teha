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
    
    func push(_ x: any Hashable) {
        path.append(x)
    }
}


struct RoutedNavigation<Root: View>: View {
    @ViewBuilder let root: (_ router: Router) -> Root
    @StateObject var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            root(router).environmentObject(router)
        }
    }
}

struct Navigation_Previews: PreviewProvider {
    static var previews: some View {
        RoutedNavigation { _ in
            Text("Hey")
        }
    }
}
