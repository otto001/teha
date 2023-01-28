//
//  LocalNotification.swift
//  teha
//
//  Created by Jette on 15.01.23.
//

import UserNotifications

/**
    The object for managing notification-related activities such as scheduling reminder.
*/
class NotificationManager {
    
    static let instance = NotificationManager() // Singleton
    
    /**
        Requests the user's authorization to allow local notifications in the form of alerts, sound, and badges on the app's icon.
        - Note:
            This request is executed only once. To change the authorization, the user would need to go to their phone settings.
    */
    func requestAuthorization() {
        
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        center.requestAuthorization(options: options) { (granted, error) in
            if let error = error {
                print("ERROR: \(error)")
            } else if granted {
                print("LOCAL NOTIFICATIONS GRANTED")
            } else {
                print("LOCAL NOTIFICATIONS DENIED")
            }
        }
        
    }
    
    /**
        Schedules reminder notifications for a given task. `task.reminderOffset` must not be `nil`. If the task contains a second reminder offset, it will schedule another notification for the same task with different offset.
        - Parameters:
            - task: The task for which to schedule the notifications. Must contain a reminder offset.
     */
    func scheduleReminderNotifications(task: THTask) {
        
        cancelPendingNotifications(taskid: task.taskId)
        
        if let reminderOffset = task.reminderOffset, let reminderOffsetSecond = task.reminderOffsetSecond{
            scheduleReminderNotification(reminderid: task.taskId + "2",
                                 title: task.title,
                                 deadline: task.deadline,
                                 reminderOffset: reminderOffsetSecond)
            
            scheduleReminderNotification(reminderid: task.taskId,
                                 title: task.title,
                                 deadline: task.deadline,
                                 reminderOffset: reminderOffset)
        } else if let reminderOffset = task.reminderOffset {
            scheduleReminderNotification(reminderid: task.taskId,
                                 title: task.title,
                                 deadline: task.deadline,
                                 reminderOffset: reminderOffset)
            
        }
        updateBadgesOfPendingRequests()
        
    }

//    func scheduleReminderNotifications(task: THTask) {
//
//        if let reminderOffset = task.reminderOffset {
//            scheduleReminderNotification(reminderid: task.taskId,
//                                 title: task.title,
//                                 deadline: task.deadline,
//                                 reminderOffset: reminderOffset)
//
//            if let reminderOffsetSecond = task.reminderOffsetSecond{
//                scheduleReminderNotification(reminderid: task.taskId + "2",
//                                     title: task.title,
//                                     deadline: task.deadline,
//                                     reminderOffset: reminderOffsetSecond)
//            }
//
//            updateBadgesOfPendingRequests()
//        }
//        cancelPendingNotifications(taskid: task.taskId)
//
//    }
    
    /**
        Schedules a reminder notification for a task.
        - Parameters:
            - reminderid: A unique identifier for the reminder of a task.
            - title: The title of the task for which the reminder notification is being scheduled.
            - deadline: The deadline of the task for which the reminder notification is being scheduled.
            - reminderOffset: The offset from the deadline at which the reminder notification should be triggered.
        - Returns:
            This function returns nothing. If the deadline is not set for the task, an error message is printed. If the reminder date cannot be created, an error message is printed.
    */
    func scheduleReminderNotification(reminderid: String, title: String?, deadline: Date?, reminderOffset: ReminderOffset) {
     
        guard let deadline = deadline else {
            print("Error: Deadline and/or reminderOffset was not set for the task!")
            return
        }
        
        // Returns current notification center
        let center = UNUserNotificationCenter.current()
        
        // Create content of notification
        let content = UNMutableNotificationContent()
        content.title = String(localized:"deadline-approaching")
        content.subtitle = title ?? ""
        content.body = deadline.formatted()
        content.sound = .default
//        content.badge = 1 as NSNumber

        // Create trigger for notification
        guard let dateComponents = reminderDateComponents(deadline: deadline, offset: reminderOffset) else {
            print("Error: Couldn't create reminder date!")
            return
        }
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false)

        // Create a notification request for notification center
        let request = UNNotificationRequest(
            identifier: reminderid,
            content: content,
            trigger: trigger)

        // Add request to notification center
        center.add(request) { (error) in
            if let error = error {
                print("ERROR: \(error)")
            }
        }

    }
    
    /**
        Given a deadline of type `Date` and an offset of type `ReminderOffset`, this function calculates the actual reminder date (deadline date minus the offset) and returns it as a value of type `DateComponents`.
        - Parameters:
            - deadline: The deadline date as a `Date` object.
            - offset: The offset from the deadline in minutes as a `ReminderOffset` object.
        - Returns:
            - A `DateComponents` object representing the reminder date.
            - If the reminder date is in the past, it will return current date + an offset of 5 seconds as a `DateComponent`.
            - If both are in the past, it will return `nil`.
        - Note:
            - If the reminder date is in the past, the function will print a warning message
            - If the deadline date and reminder date are both in the past, it will print an error message
    */
    func reminderDateComponents(deadline: Date, offset: ReminderOffset) -> DateComponents? {
        let timeBuffer = 5
        let calendar = Calendar.current
        let reminder = calendar.date(byAdding: .minute, value: -offset.rawValue, to: deadline)
        
        guard let reminder = reminder else {
            print("Error: Couldn't create a reminder date!")
            return nil
        }
        
        let now = Date()
        let deadlineCompare = calendar.compare(deadline, to: now, toGranularity: .second)
        let reminderCompare = calendar.compare(reminder, to: now, toGranularity: .second)
        
        if deadlineCompare == .orderedAscending && reminderCompare == .orderedAscending {
            print("Error: deadline date and reminder date are in the past!")
            return nil
        } else if reminderCompare == .orderedAscending {
            print("Warning: reminder date is in the past!")
            guard let currentReminder = calendar.date(byAdding: .second, value: timeBuffer, to: now) else {
                print("Error: Couldn't create current reminder date!")
                return nil
            }
            return calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentReminder)
        } else {
            return calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminder)
        }
    }

    /**
        This function updates the badge property of all pending notifications.
        It first retrieves all pending notifications from the notification center and sorts them in ascending order by their trigger date.
        Then it iterates through the requests and assigns a badge number to each request, starting with the number of delivered notifications +1.
        Finally, it updates the notification request in the notification center with the new badge value.
    */
    func updateBadgesOfPendingRequests() {
        var badgeCounter = getNumberOfDeliveredNotifications() // TODO: Need to remove this by an intern value if we want the badge to be independent of the NotificationCenter
        orderPendingRequestsAscending { orderedRequests in
            for request in orderedRequests {
                badgeCounter += 1
                let content = request.content.mutableCopy() as! UNMutableNotificationContent
                content.badge = badgeCounter as NSNumber
                // update request by setting its current badge to badgeCounter
                let newRequest = UNNotificationRequest(identifier: request.identifier, content: content, trigger: request.trigger)
                UNUserNotificationCenter.current().add(newRequest) { error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    /**
        This function sorts all pending notifications in ascending order by their trigger date.
        It retrieves all pending notifications from the notification center and sorts them using a custom comparator, by comparing the trigger date of each request.
        The function takes a completion closure as an argument, which is executed once the requests are sorted and passed to it.
        The closure takes an array of UNNotificationRequest as an argument, which contains the sorted requests.
    */

    func orderPendingRequestsAscending(completion: @escaping ([UNNotificationRequest]) -> Void) {
            
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            
            let calendar = Calendar.current
            let sortedRequests = requests.sorted {
                if let trigger1 = $0.trigger as? UNCalendarNotificationTrigger,
                   let trigger2 = $1.trigger as? UNCalendarNotificationTrigger {
                    
                    let date1 = calendar.date(from: trigger1.dateComponents)
                    let date2 = calendar.date(from: trigger2.dateComponents)
                    
                    return date1! < date2!
                }
                return false
            }
            completion(sortedRequests)
        }
    }
    
    /// Sets the badge count of the app’s icon to the number of delivered notifications
    func updateBadgeCount() {

        let center = UNUserNotificationCenter.current()
        center.setBadgeCount(getNumberOfDeliveredNotifications())

    }
    
    /// Removes all notifications (pending or delivered) in the current notification center
    /// and updates the badge count to 0
    func cancelAllNotifications() {
        
        print("Cancel all notifications!")
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        updateBadgeCount()

    }
    
    /// Removes all delivered notifications in the current notification center
    /// and updates the badge count to 0
    func cancelDeliveredNotifications() {
        
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        updateBadgeCount()

    }
    
    /// Removes all pending notifications that are scheduled with taskid in the current notification center
    func cancelPendingNotifications(taskid: String) {
        
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [taskid, taskid + "2"])
            
    }
    
    /// Removes pending notifications that belong to the notificationids in the current notification center
    func cancelPendingNotifications(notificationids: [String]) {
        
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: notificationids)
            
    }
    
    /// Cancels any scheduled notifications associated with each task.
    func cancelPendingNotificationsforTasks(tasks: NSSet?) {
        if let tasks=tasks {
            let taskArray = tasks.allObjects as! [THTask]
            for task in taskArray {
                cancelPendingNotifications(taskid: task.taskId)
            }
        }
    }
    
    /// Returns number of pending notifications in the current notification center
    func getNumberOfPendingNotifications() -> Int {
        
        // Semaphore is used to synchronize the asynchronic behaviour of the
        // completion handler in getPendingNotificationRequests()
        let semaphore = DispatchSemaphore(value: 0)
        var count: Int = 0
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            count = requests.count
            semaphore.signal()
        }
        semaphore.wait() // Wait until completion handler is done
        return count
        
    }
    
    /// Returns number of delivered notifications in the current notification center
    func getNumberOfDeliveredNotifications() -> Int {
        
        // Semaphore is used to synchronize the asynchronic behaviour of the
        // completion handler in getDeliveredNotifications()
        let semaphore = DispatchSemaphore(value: 0)
        var count: Int = 0
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications { requests in
            count = requests.count
            semaphore.signal()
        }
        semaphore.wait() // Wait until completion handler is done
        return count
        
    }
    
}

