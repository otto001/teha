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
    
    func scheduleNotification() {
        
        let center = UNUserNotificationCenter.current()
        
        // Create content of notification
        let content = UNMutableNotificationContent()
        content.title = "deadline-approaching" // TODO
        content.subtitle = "name-of-the-task" // TODO
        content.sound = .default
        content.badge = (self.numOfPendingNotifications + 1) as NSNumber
        
        self.numOfPendingNotifications += 1

        // Create trigger for notification
        //var dateComponents = DateComponents()
        //dateComponents.hour = 15 // TODO
        //dateComponents.minute = 10 // TODO
        let date = Date().addingTimeInterval(10)
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false)
        
        // Create a notification request for notification center
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(
            identifier: uuidString,
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
    
//    func scheduleNotification(task: THTask) {
//
//        // Returns current notification center
//        let center = UNUserNotificationCenter.current()
//
//        // Necessary information about the task
//        let taskname = task.title
//        let deadline = task.targetCompletionDate
//        let taskid = task.id // TODO: jedes Objekt hat automatisch eine eigene id
//        let reminder = task.reminder
//
////        var dateComponents = DateComponents()
////        dateComponents.day = 10
////        dateComponents.hour = 15
////        dateComponents.minute = 10
////
////        var dateComponents2 = DateComponents()
////        dateComponents.minute = 5
////
////        guard let reminderDate = dateComponents.minute - dateComponents2.minute else {
////            return
////        }
//
//        // Create content of notification
//        let content = UNMutableNotificationContent()
//        content.title = "deadline-approaching" // TODO
//        content.subtitle = taskname
//        content.sound = .default
//        content.badge = (self.numOfPendingNotifications + 1) as NSNumber
//
//        self.numOfPendingNotifications += 1
//
//        // Create trigger for notification
//        let dateComponents = deadline // TODO
//        let trigger = UNCalendarNotificationTrigger(
//            dateMatching: dateComponents,
//            repeats: false)
//
//        // Create a notification request for notification center
//        let request = UNNotificationRequest(
//            identifier: taskid,
//            content: content,
//            trigger: trigger)
//
//        // Add request to notification center
//        center.add(request) { (error) in
//            // Check the error parameter and handle any errors
//            if let error = error {
//                print("ERROR: \(error)")
//            }
//        }
//
//    }
    
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

