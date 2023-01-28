//
//  ReminderPicker.swift
//  teha
//
//  Created by Jette on 17.01.23.
//

import SwiftUI

/// A SwiftUI view that allows users to select a reminder offset from a list of options.
/// The view will show a picker if the user has authorized notifications, otherwise it will show a button that prompts the user to open settings and allow notifications.
struct ReminderPicker: View {
    /// The currently selected reminder offset.
    @Binding var selection: ReminderOffset?
    /// The current status of the user's authorization for notifications.
    @State var status: UNAuthorizationStatus
    // A flag to determine whether the alert should be shown to prompt the user to open settings and allow notifications.
    @State private var showAlert = false
    /// The title of the picker.
    let title: LocalizedStringKey
    
    /// Initializes the view with a title and a binding to the selected reminder offset. It sets the status of the user's authorization for notifications to not determined.
    /// - Parameters:
    ///   - title: The title of the picker.
    ///   - selection: A binding to the selected reminder offset.
    init(title: LocalizedStringKey, selection: Binding<ReminderOffset?>) {
        self.title = title
        self.status = .notDetermined
        self._selection = selection
    }
    
    /// Checks the current status of the user's authorization for notifications and updates the status.
    func checkAuthorization() {
        let semaphore = DispatchSemaphore(value: 0)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.status = settings.authorizationStatus
            }
            semaphore.signal()
        }
        semaphore.wait()
    }
    
    /// `body` view dispalys  either the picker or the button, depending on the authorization status.
    /// It contains an `onAppear` function which checks for authorization status every time the view appears.
    /// And also an `onReceive` function which listens to the `UIApplication.willEnterForegroundNotification` and calls
    /// the `checkAuthorization` function so that in case the user changed the authorization in settings the view will be updated accordingly.
    var body: some View {
        Group {
            
            if status == .authorized {
                
                // Show the picker if the user has authorized notifications
                Picker(title, selection: $selection) {
                    Text("none").tag(Optional<ReminderOffset>.none)
                    Divider()
                    ForEach(ReminderOffset.allCases) { reminderOffset in
                        Text(reminderOffset.name).tag(Optional.some(reminderOffset))
                    }
                }
                
            } else {
                
                // Show the button and alert if the user has not authorized notifications
                Button {
                    self.showAlert.toggle()
                } label: {
                    Label("reminder-add", systemImage: "exclamationmark.triangle")
                }
                .foregroundColor(.red)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("notifications-allow"), message: Text("notifications-allow-message"), primaryButton: .default(Text("settings-open"), action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }), secondaryButton: .cancel())
                }
                
            }
            
        }
        .onAppear {
            self.checkAuthorization()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            self.checkAuthorization()
        }
    }
    
}


struct ReminderPicker_Previews: PreviewProvider {
    
    struct ReminderPickerPreview: View {
        @State var selection: ReminderOffset? = nil
        
        var body: some View {
            ReminderPicker(title:"reminder", selection: $selection)
        }
    }
    
    static var previews: some View {
        Form {
            ReminderPickerPreview()
        }
    }
}
