//
//  ReminderPicker.swift
//  teha
//
//  Created by Jette on 17.01.23.
//

import SwiftUI

class NotificationStatus: ObservableObject {
    @Published var status: UNAuthorizationStatus = .notDetermined
}

struct ReminderPicker: View {
    @ObservedObject var notificationStatus: NotificationStatus
    @Binding var internalSelection: ReminderOffsetTag
    @State private var showAlert = false
    
    init(selection: Binding<ReminderOffset?>) {
        
        self.notificationStatus = NotificationStatus()
        
        self._internalSelection = Binding {
            return ReminderOffsetTag(selection.wrappedValue)
        } set: { reminderOffsetTag in
            selection.wrappedValue = reminderOffsetTag.value
        }
        
        checkAuthorization()
        
    }
    
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationStatus.status = settings.authorizationStatus
            }
        }
    }


    var body: some View {
        Group {
            
            if notificationStatus.status == .authorized {
                
                Picker("reminder-add", selection: $internalSelection) {
                    Text("none").tag(ReminderOffsetTag(nil))

                    ForEach(ReminderOffset.allCases) { reminderOffset in
                        Text(reminderOffset.name).tag(ReminderOffsetTag(reminderOffset))
                    }
                }
                
            } else {
                
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
            
        }.environmentObject(notificationStatus)
    }


}

extension ReminderPicker {
    struct ReminderOffsetTag: Hashable {
        let value: ReminderOffset?
        
        init(_ value: ReminderOffset?) {
            self.value = value
        }
    }
}

struct ReminderPicker_Previews: PreviewProvider {
    
    struct ReminderPickerPreview: View {
        @State var selection: ReminderOffset? = nil

        var body: some View {
            ReminderPicker(selection: $selection)
        }
    }
    
    static var previews: some View {
        Form {
            ReminderPickerPreview()
        }
    }
}
