//
//  RefreshModifier.swift
//  teha
//
//  Created by Matteo Ludwig on 29.01.23.
//

import Foundation
import SwiftUI

/// Configures a timer to update the bound now Date once per minute with the current date rounded to the current minute.
/// Use a State wrapped Date in the view you want to update automatically as the bound now value.
struct AutoRefreshModifier: ViewModifier {
    let now: Binding<Date>
    
    // Check once per second if time has changed
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    private func updateNow() {
        // Round to current minute
        // We need to subtract one minute, as setting seconds to 0 seems to jump to the next minute for some reason
        var newNow = Calendar.current.date(bySetting: .second, value: 0, of: Date.now)!
        newNow = Calendar.current.date(byAdding: .minute, value: -1, to: newNow)!
        
        if newNow != self.now.wrappedValue {
            // Only send an actual update once now changes (i.e., once per minute)
            self.now.wrappedValue = newNow
        }
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                self.updateNow()
            }
            .onReceive(timer) { _ in
                self.updateNow()
            }
    }
}

extension View {
    
    /// Configures a timer to update the bound now Date once per minute with the current date rounded to the current minute.
    /// Use a State wrapped Date in the view you want to update automatically as the Binding.
    /// - Parameter now: The Bound now value that will be updated.
    func autoRefresh(now: Binding<Date>) -> some View {
        modifier(AutoRefreshModifier(now: now))
    }
}


