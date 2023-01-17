//
//  LocalNotification.swift
//  teha
//
// - unendlich viele Reminder erstellen
// - Reminder badge count erst löschen wenn task completed oder gelöscht
// - Nachrichten -> auch in der App wiederspiegeln
//
// - Bar macht mehr Sinn wenn Aufgabe Unteraufgaben bekommen kann
// - Fokus mehr auf Effizienz und Zeitmanagment
// ------> Projekt Priorität soll nicht ungebdingt von der Aufgabe geerbt werden - eher keine Priorität
// - Text Mining mit drin? bei Text Suche
//
//  Created by Jette on 15.01.23.
//

import SwiftUI
import UserNotifications

class NotificationManager {
    
    static let instance = NotificationManager() // Singleton
    var numOfPendingNotifications: Int = 0
    
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
    
    func scheduleNotification(task: THTask) {

        var test: Bool = true // TODO: remove later
        
        // Returns current notification center
        let center = UNUserNotificationCenter.current()

        // Create content of notification
        let content = UNMutableNotificationContent()
        content.title = String(localized:"deadline-approaching")
        content.subtitle = task.title ?? ""
        
        if let deadline = task.deadline {
            content.body = deadline.formatted()
        }
        
        content.sound = .default
        content.badge = (self.numOfPendingNotifications + 1) as NSNumber

        self.numOfPendingNotifications += 1

        // Create trigger for notification
        
        var dateComponents: DateComponents = DateComponents() // TODO: remove later
        
        if test { // TODO: remove later
            let date = Date().addingTimeInterval(10)
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
            identifier: task.objectID.uriRepresentation().absoluteString,
            content: content,
            trigger: trigger)

        // Add request to notification center
        center.add(request) { (error) in
            // Check the error parameter and handle any errors
            if let error = error {
                print("ERROR: \(error)")
            }
        }

    }
    
    func cancelAllNotifications() {
        
        print("Cancel all notifications!")
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        self.numOfPendingNotifications = 0
        center.setBadgeCount(self.numOfPendingNotifications)
        

    }
    
    func cancelDeliveredNotifications() {
        
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        // TODO: Badge Count also needs to be modified

    }
    
    func cancelSpecificNotification(taskid: String) {
        
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [taskid])
        self.numOfPendingNotifications -= 1
        center.setBadgeCount(self.numOfPendingNotifications)


    }
    
}

