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
        Requests the user’s authorization to allow local notifications in form from alert, it's corresponding sound and badge count on the app's icon.
        This will be executed once, afterwards this property needs to be changed by the user in phone settings.
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
        Sends a request to the notification center based on the reminders set in task already pending request of the current task will be canceled.
     */
    func scheduleNotification(task: THTask) {
     
        guard let deadline=task.deadline, let reminderOffset=task.reminderOffset else {
            print("Error: Deadline and/or reminderOffset was not set for the task!")
            return
        }
        
        // Returns current notification center
        let center = UNUserNotificationCenter.current()
        
        // Remove already scheduled reminders, which might not be up to date anymore
        cancelPendingNotifications(taskid: task.taskId)
        
        // Create content of notification
        let content = UNMutableNotificationContent()
        content.title = String(localized:"deadline-approaching")
        content.subtitle = task.title ?? ""
        if let deadline = task.deadline {
            content.body = deadline.formatted()
        }
        content.sound = .default
        content.badge = (getNumberOfDeliveredNotifications() + getNumberOfPendingNotifications() + 1) as NSNumber // TODO: This does not work!

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
            identifier: task.taskId,
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
        center.removePendingNotificationRequests(withIdentifiers: [taskid])
            
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

