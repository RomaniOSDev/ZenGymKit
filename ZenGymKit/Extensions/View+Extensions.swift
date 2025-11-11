//
//  View+Extensions.swift
//  ZenGym
//
//

import SwiftUI

extension View {
    func hideKeyboardOnTap() -> some View {
        self.background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
        )
    }
    
    func hideKeyboardOnScroll() -> some View {
        self.simultaneousGesture(
            DragGesture()
                .onChanged { _ in
                    hideKeyboard()
                }
        )
    }
    
    func hideKeyboardOnInteraction() -> some View {
        self.background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
        )
        .simultaneousGesture(
            DragGesture()
                .onChanged { _ in
                    hideKeyboard()
                }
        )
    }
    
    func hideKeyboardOnTapOutside() -> some View {
        self.background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
        )
    }
    
    func hideKeyboardOnTapOutsideImproved() -> some View {
        self.background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
        )
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            hideKeyboard()
        }
    }
    
    func dismissKeyboardOnTapAndScroll() -> some View {
        self.background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
        )
        .onTapGesture {
            hideKeyboard()
        }
        .simultaneousGesture(
            DragGesture()
                .onChanged { _ in
                    hideKeyboard()
                }
        )
    }
    
    func dismissKeyboardOnTapAndScrollAggressive() -> some View {
        self.background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
        )
        .onTapGesture {
            hideKeyboard()
        }
        .simultaneousGesture(
            DragGesture()
                .onChanged { _ in
                    hideKeyboard()
                }
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    hideKeyboard()
                }
        )
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
} 