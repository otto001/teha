//
//  THTimeLogEntry+CoreDataClass.swift
//  teha
//
//  Created by Matteo Ludwig on 01.07.24.
//
//

import Foundation
import CoreData

@objc(THTimeLogEntry)
public class THTimeLogEntry: NSManagedObject {
    static var all: NSFetchRequest<THTimeLogEntry> = {
        let all = THTimeLogEntry.fetchRequest()
        all.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]
        return all
    }()
}
