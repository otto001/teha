//
//  LocalNotification.swift
//  teha
//
// - unendlich viele Reminder erstellen
// - Reminder badge count erst löschen wenn task completed oder gelöscht
// - Nachrichten -> auch in der App wiederspiegeln
//
// - Fokus mehr auf Effizienz und Zeitmanagment
// ------> Projekt Priorität soll nicht ungebdingt von der Aufgabe geerbt werden - eher keine Priorität
// - Text Mining mit drin? bei Text Suche
//
//  Created by Jette on 15.01.23.
//

import UserNotifications

/// The object for managing notification-related activities such as scheduling reminder.
class NotificationManager {
    
    static let instance = NotificationManager() // Singleton
    
    /// Requests the user’s authorization to allow local notifications in form from
    /// alert, it's corresponding sound and badge count on the app's icon.
    /// This will be executed once, afterwards this property needs to be changed by
    /// the user in phone settings.
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
    
    /// Sends a request to the notification center based on the reminders set in task
    /// already pending request of the current task will be canceled
    func scheduleNotification(task: THTask) {
        
        var test: Bool = true // TODO: remove later
        
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
        var dateComponents: DateComponents = DateComponents() // TODO: remove later
        
        if test { // TODO: remove later
            let date = Date().addingTimeInterval(30)
            dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: date)
        } else {
            if let deadline = task.deadline {
                let deadlineDateComponents = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: deadline)
            }
            // TODO: create actual reminder time
//        guard let reminderDate = dateComponents.minute - dateComponents2.minute else {
//            return
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
            // TODO: Check the error parameter and handle any errors
            if let error = error {
                print("ERROR: \(error)")
            }
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

