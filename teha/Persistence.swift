//
//  Persistence.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "teha")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistenceController {
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        var projects = [THProject]()
        for priority in Priority.allCases {
            for i in 0..<5 {
                let newItem = THProject(context: viewContext)
                newItem.name = "Project \(i)"
                newItem.completed = i >= 3
                newItem.creationDate = .now
                newItem.priority = priority
                newItem.color = ColorChoice.baseColors[i]
                projects.append(newItem)
            }
        }
        
        
        for i in 0...10 {
            let newItem = THTask(context: viewContext)
            newItem.title = "Task \(i)"
            newItem.project = i <= 8 ? projects[i] : nil
            newItem.priority = newItem.project?.priority ?? .normal
            
            newItem.deadline = .now + TimeInterval(exactly: 60 * 60 * pow(2.0, Double(i+2)))! - .day
            newItem.earliestStartDate = newItem.deadline! - TimeInterval.week
            newItem.estimatedWorktime = .init(hours: 4, minutes: 0)
            
            newItem.completionProgress = Double(i)/10
            newItem.startDate = newItem.completionProgress > 0 ? .now : nil
            newItem.completionDate = newItem.completionProgress >= 1 ? .now : nil
            
        }
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
