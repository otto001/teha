//
//  LocalNotification.swift
//  teha
//
//  Created by Jette on 15.01.23.
//

import UserNotifications

/**
    The object for managing notification-related activities such as scheduling reminder or geofencing notifications.
*/
class NotificationManager {
    
    static let instance = NotificationManager() // Singleton
    
    private var notificationCenter: UNUserNotificationCenter { .current() }
    
    /**
        Requests the user's authorization to allow local notifications in the form of alerts, sound, and badges on the app's icon.
        - Note:
            This request is executed only once. To change the authorization, the user would need to go to their phone settings.
    */
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        self.notificationCenter.requestAuthorization(options: options) { (granted, error) in
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
        
        self.cancelPendingNotifications(for: task)
        
        if let deadlineDate = task.deadlineDate {
            if let reminderOffset = task.reminderFirstOffset {
                self.scheduleReminderNotification(reminderId: task.taskNotificationId(reminderIndex: 0),
                                                  title: task.title,
                                                  deadline: deadlineDate,
                                                  reminderOffset: reminderOffset)
            }
            if let reminderOffset = task.reminderSecondOffset {
                self.scheduleReminderNotification(reminderId: task.taskNotificationId(reminderIndex: 1),
                                                  title: task.title,
                                                  deadline: deadlineDate,
                                                  reminderOffset: reminderOffset)
            }
        }
        self.updateBadgesOfPendingRequests()
    }

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
    func scheduleReminderNotification(reminderId: String, title: String?, deadline: Date?, reminderOffset: ReminderOffset) {
        guard let deadline = deadline else {
            print("Error: Deadline and/or reminderOffset was not set for the task!")
            return
        }
        
        // Create content of notification
        let content = UNMutableNotificationContent()
        content.title = String(localized:"deadline-approaching")
        content.subtitle = title ?? ""
        content.body = deadline.formatted()
        content.sound = .default

        // Create trigger for notification
        guard let dateComponents = self.reminderDateComponents(deadline: deadline, offset: reminderOffset) else {
            print("Error: Couldn't create reminder date!")
            return
        }
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false)

        // Create a notification request for notification center
        let request = UNNotificationRequest(
            identifier: reminderId,
            content: content,
            trigger: trigger)

        // Add request to notification center
        self.notificationCenter.add(request) { (error) in
            if let error = error {
                print("ERROR: \(error)")
            }
        }

    }
    
    /**
    Displays a time-based notification to the current time with the given task title and potential offset.
    - Parameters:
        - title: The title of the task. If `nil`, the function returns without doing anything.
        - requestIdentifier: A unique string identifier for the notification request.
        - offset: The time interval from now after which the notification should be triggered.
    - Returns:
        None.
    */
    func displayLocationNotificationNow(title: String?, requestIdentifier: String, offset: TimeInterval) {
        // Create content of notification
        let content = UNMutableNotificationContent()
        content.title = String(localized: "location-arrived-title")
        if let title = title {
            content.body = String(localized: "\(title)-location-arrived-body")
        } else {
            return
        }
        content.sound = .default

        // Create trigger for notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: offset, repeats: false)

        // Create a notification request for notification center
        let request = UNNotificationRequest(
            identifier: requestIdentifier + "L", // An "L" is appended to the requestIdentifier to make the Id unique.
            content: content,
            trigger: trigger)

        // Add request to notification center
        self.notificationCenter.add(request) { (error) in
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
//        var badgeCounter = getNumberOfDeliveredNotifications() // WARNING: This should later be removed by an internal reminder counter as we want the badge to be independent of the Notification Center
//        orderPendingRequestsAscending { orderedRequests in
//            for request in orderedRequests {
//                badgeCounter += 1
//                let content = request.content.mutableCopy() as! UNMutableNotificationContent
//                content.badge = badgeCounter as NSNumber
//                // update request by setting its current badge to badgeCounter
//                let newRequest = UNNotificationRequest(identifier: request.identifier, content: content, trigger: request.trigger)
//                UNUserNotificationCenter.current().add(newRequest) { error in
//                    if let error = error {
//                        print("Error: \(error.localizedDescription)")
//                    }
//                }
//            }
//        }
    }
    
    /**
        This function sorts all pending notifications in ascending order by their trigger date.
        It retrieves all pending notifications from the notification center and sorts them using a custom comparator, by comparing the trigger date of each request.
        The function takes a completion closure as an argument, which is executed once the requests are sorted and passed to it.
        The closure takes an array of UNNotificationRequest as an argument, which contains the sorted requests.
    */
    func orderPendingRequestsAscending(completion: @escaping ([UNNotificationRequest]) -> Void) {
        self.notificationCenter.getPendingNotificationRequests { requests in
            
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
        self.notificationCenter.setBadgeCount(0)
    }
    
    /// Removes all notifications (pending or delivered) in the current notification center
    /// and updates the badge count to 0
    func cancelAllNotifications() {
        self.notificationCenter.removeAllDeliveredNotifications()
        self.notificationCenter.removeAllPendingNotificationRequests()
        self.updateBadgesOfPendingRequests()
    }
    
    /// Removes all delivered notifications in the current notification center
    /// and updates the badge count to 0
    func cancelDeliveredNotifications() {
        self.notificationCenter.removeAllDeliveredNotifications()
        self.updateBadgesOfPendingRequests()
    }
    
    /// Removes all pending notifications that are scheduled with taskid in the current notification center
    func cancelPendingNotifications(for task: THTask) {
        self.cancelPendingNotifications(for: [task])
    }
    
    /// Cancels any scheduled notifications associated with each task.
    func cancelPendingNotifications<T: Sequence>(for tasks: T) where T.Element == THTask {
        let taskNotificationIds = tasks.flatMap { task in
            [task.taskNotificationId(reminderIndex: 0), task.taskNotificationId(reminderIndex: 1)]
        }
        self.cancelPendingNotifications(with: taskNotificationIds)
    }
    
    /// Cancels any scheduled notifications that are associated with the request identifiers.
    func cancelPendingNotifications(with requestIdentifiers: [String]) {
        self.notificationCenter.removePendingNotificationRequests(withIdentifiers: requestIdentifiers)
    }
    
    /// Returns number of pending notifications in the current notification center
    func pendingNotificationRequests() async -> [UNNotificationRequest] {
        return await withCheckedContinuation { continuation in
            self.notificationCenter.getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }
    
    /// Returns number of delivered notifications in the current notification center
    func deliveredNotifications() async -> [UNNotification] {
        return await withCheckedContinuation { continuation in
            self.notificationCenter.getDeliveredNotifications { notifications in
                continuation.resume(returning: notifications)
            }
        }
    }
    
}

