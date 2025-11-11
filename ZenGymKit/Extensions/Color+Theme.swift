//
//  Color+Theme.swift
//  ZenGymKit
//
//

import SwiftUI

extension Color {
    static let appBackground = Color("Color1")
    static let appSurface = Color("Color2")
    static let appAccent = Color("Color3")
    
    static var appAccentSecondary: Color { Color("Color3").opacity(0.85) }
    static var appAccentTertiary: Color { Color("Color3").opacity(0.6) }
    static var appSurfaceStrong: Color { Color("Color2").opacity(0.9) }
    static var appSurfaceMedium: Color { Color("Color2").opacity(0.6) }
    static var appSurfaceSoft: Color { Color("Color2").opacity(0.3) }
    
    static let appGradient: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [.appBackground, .appSurface]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static func appSurfaceOpacity(_ opacity: Double) -> Color {
        Color("Color2").opacity(opacity)
    }
    
    static func appAccentOpacity(_ opacity: Double) -> Color {
        Color("Color3").opacity(opacity)
    }
}

