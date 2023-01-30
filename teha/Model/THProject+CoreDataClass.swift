//
//  Project+CoreDataClass.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//
//

import Foundation
import CoreData
import SwiftUI


@objc(THProject)
public class THProject: NSManagedObject {

}

extension THProject {
    
    /// The priority of the project assigned by the user
    var priority: Priority {
        get {
            return Priority(rawValue: Int(self.priorityNumber))!
        }
        set {
            self.priorityNumber = Int16(newValue.rawValue)
        }
    }
    
    /// The ColorChoice assigned to this project by the user 
    var color: ColorChoice {
        get {
            return ColorChoice(rawValue: self.colorCode ?? "") ?? .red
        }
        
        set {
            self.colorCode = newValue.rawValue
        }
    }
}

//MARK: FetchRequests
extension THProject {
    
    /// A fetch request fetching all projects sorted by: priority (desc), creationDate (asc)
    static var all: NSFetchRequest<THProject> {
        let request = THProject.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \THProject.priorityNumber, ascending: false),
                                   NSSortDescriptor(keyPath: \THProject.creationDate, ascending: true)]
        return request
    }
}

