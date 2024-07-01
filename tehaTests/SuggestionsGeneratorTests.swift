//
//  tehaTests.swift
//  tehaTests
//
//  Created by Matteo Ludwig on 28.01.23.
//

import XCTest
import CoreData
@testable import teha

fileprivate let isoDateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
    return formatter
}()

struct TaskDescription {
    let earliestStart: String?
    let deadline: String
    let worktime: Worktime
    let priority: Priority
    
    func task(context: NSManagedObjectContext, title: String) -> THTask {
        let task = THTask(context: context)
        let taskDescription = THTaskDescription(context: context)
        task.taskDescription = taskDescription
        taskDescription.estimatedWorktime = worktime
        taskDescription.priority = priority
        taskDescription.earliestStartDate = earliestStart.map { isoDateFormatter.date(from: $0)! }
        taskDescription.deadlineDate = isoDateFormatter.date(from: deadline)!
        taskDescription.title = title
        task.updateFromDescription(offset: 0)
        return task
    }
}


final class SuggestionsGeneratorTests: XCTestCase {
    
    lazy var persistentContainer: NSPersistentContainer = {
        return PersistenceController.shared.container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        for task in try! self.managedObjectContext.fetch(THTask.all) {
            self.managedObjectContext.delete(task)
        }
        try self.managedObjectContext.save()
    }
    
    func makeTasks(_ descriptions: [TaskDescription]) -> [THTask] {
        return descriptions.enumerated().map { (i, description) in
            description.task(context: managedObjectContext, title: "Task \(i)")
        }
    }
    
    func makeExpectedResult(isFeasible: Bool, tasks: [(THTask, String)]) -> SuggestionsGenerator.Result {
        
        let tasksWithLatestStartDate: [SuggestionsGenerator.TaskWithLatestStartDate] = tasks.map { (task, latestStartDate) in
            return .init(task: task, latestStartDate: isoDateFormatter.date(from: latestStartDate)!)
        }
        return SuggestionsGenerator.Result(tasks: tasksWithLatestStartDate, isFeasible: isFeasible)
    }
    
    func generateResult(for: [THTask]) async throws -> SuggestionsGenerator.Result {
        let generator = SuggestionsGenerator(now: isoDateFormatter.date(from: "2000-06-01T00:00")!, managedObjectContext: managedObjectContext)
        return try await generator.calculate()
    }
    
    func resultIsEqual(gotten: SuggestionsGenerator.Result, expected: SuggestionsGenerator.Result, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(gotten.isFeasible, expected.isFeasible, file: file, line: line)
        
        for (gottenTask, expectedTask) in zip(gotten.tasks, expected.tasks) {
            XCTAssertEqual(gottenTask.task.id, expectedTask.task.id, file: file, line: line)
            XCTAssertEqual(gottenTask.latestStartDate, expectedTask.latestStartDate, file: file, line: line)
        }
        
    }

    func testFeasibleScenario1() async throws {
        
        let tasks = makeTasks([
            .init(earliestStart: "2000-06-01T08:00", deadline: "2000-06-01T08:55", worktime: .init(hours: 0, minutes: 25), priority: .normal),
            .init(earliestStart: "2000-06-01T08:25", deadline: "2000-06-01T09:05", worktime: .init(hours: 0, minutes: 25), priority: .normal),
            .init(earliestStart: "2000-06-01T08:25", deadline: "2000-06-01T08:35", worktime: .init(hours: 0, minutes: 10), priority: .normal)
            ])
        
        let result = try await generateResult(for: tasks)
        let expected = makeExpectedResult(isFeasible: true, tasks: [
            (tasks[0], "2000-06-01T08:05"),
            (tasks[2], "2000-06-01T08:25"),
            (tasks[1], "2000-06-01T08:40"),
        ])
        resultIsEqual(gotten: result, expected: expected)
    }
    
    func testFeasibleScenario2() async throws {
        
        let tasks = makeTasks([
            .init(earliestStart: "2000-06-01T08:20", deadline: "2000-06-01T08:55", worktime: .init(hours: 0, minutes: 25), priority: .normal),
            .init(earliestStart: "2000-06-01T08:25", deadline: "2000-06-01T09:05", worktime: .init(hours: 0, minutes: 25), priority: .normal),
            .init(earliestStart: "2000-06-01T08:25", deadline: "2000-06-01T08:35", worktime: .init(hours: 0, minutes: 10), priority: .normal)
            ])
        
        let result = try await generateResult(for: tasks)
        let expected = makeExpectedResult(isFeasible: true, tasks: [
            (tasks[1], "2000-06-01T08:05"),
            (tasks[0], "2000-06-01T08:20"),
            (tasks[2], "2000-06-01T08:25"),
        ])
        resultIsEqual(gotten: result, expected: expected)
    }

    func testPerformance() throws {
        
        var taskDescriptions = [TaskDescription]()
        
        for _ in 0..<20 {
            taskDescriptions.append(.init(earliestStart: nil, deadline:  "2000-06-14T16:00", worktime: .init(hours: 8, minutes: 0), priority: .normal))
        }
        
        let tasks = makeTasks(taskDescriptions)
        
        
        
        measure {
            let exp = expectation(description: "Finished")
            
            Task {
                _ = try await generateResult(for: tasks)
                exp.fulfill()
            }
            
            wait(for: [exp], timeout: 100.0)
            print("L")
        }
    }

}
