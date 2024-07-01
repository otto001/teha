//
//  FormSheetNavigationBar.swift
//  teha
//
//  Created by Matteo Ludwig on 10.01.23.
//

import Foundation
import SwiftUI

/// Configures the Navigation Bar for embedding a Form in a Sheet
/// Adds a navigation title (always inline), a leading Cancel Button, and a trailing Done/Add Button.
/// The Done/Add Button is disabled when valid is false.
/// When editing is true, the Done/Add Button is labeled "Done", otherwise its is labeled as "Add".
/// The closures done and cancel are called when their respective Buttons are pressed.
struct FormSheetNavigationBar: ViewModifier {
    let navigationTitle: String
    let editing: Bool
    let valid: Bool
    let done: () -> Void
    let cancel: () -> Void

    func body(content: Content) -> some View {
            content
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey(editing ? "done" : "add")) {
                        done()
                    }
                    .disabled(!valid)
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("cancel"), role: .cancel) {
                        cancel()
                    }
                }
            }
               
        }
}

extension View {
    /// Configures the Navigation Bar for embedding a Form in a Sheet
    /// Adds a navigation title (always inline), a leading Cancel Button, and a trailing Done/Add Button.
    /// The Done/Add Button is disabled when valid is false.
    /// When editing is true, the Done/Add Button is labeled "Done", otherwise its is labeled as "Add".
    /// The closures done and cancel are called when their respective Buttons are pressed.
    /// - Parameter navigationTitle: The navigation title of the form.
    /// - Parameter editing: Should be true when the form is being used to edit an existing record and false when used to create a new record. Decides the label of the Done/Add Button.
    /// - Parameter valid: Should be true when the record being edited/created can be saved, and false when the user input is invalid and cannot be saved.
    /// - Parameter done: The closure being called when the Done/Add Button is pressed.
    /// - Parameter cancel: The closure being called when the Cancel Button is pressed.
    func formSheetNavigationBar(navigationTitle: String, editing: Bool, valid: Bool, done: @escaping () -> Void, cancel: @escaping () -> Void) -> some View {
        return modifier(FormSheetNavigationBar(navigationTitle: navigationTitle, editing: editing, valid: valid, done: done, cancel: cancel))
    }
}
