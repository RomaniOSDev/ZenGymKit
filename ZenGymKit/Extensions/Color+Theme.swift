//
//  Color+Theme.swift
//  ZenGymKit
//
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension Color {
    static let appBackground = Color("Color1")
    static let appSurface = Color("Color2")
    static let appAccent = Color("Color3")
    
    static var appAccentSecondary: Color { Color("Color3").opacity(0.85) }
    static var appAccentTertiary: Color { Color("Color3").opacity(0.6) }
    static var appSurfaceStrong: Color { lightenColor(named: "Color2", amount: 0.22).opacity(0.9) }
    static var appSurfaceMedium: Color { lightenColor(named: "Color2", amount: 0.24).opacity(0.6) }
    static var appSurfaceSoft: Color { lightenColor(named: "Color2", amount: 0.28).opacity(0.35) }
    
    static var appBackgroundLight: Color {
        lightenColor(named: "Color1", amount: 0.18)
    }

    static var appSurfaceLight: Color {
        lightenColor(named: "Color2", amount: 0.18)
    }

    static let appGradient: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [.appBackgroundLight, .appSurfaceLight]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static func appSurfaceOpacity(_ opacity: Double) -> Color {
        lightenColor(named: "Color2", amount: 0.2).opacity(opacity)
    }
    
    static func appAccentOpacity(_ opacity: Double) -> Color {
        Color("Color3").opacity(opacity)
    }

    static let appTextPrimary = Color.white
    static let appTextSecondary = Color.white.opacity(0.7)
    static let appTextTertiary = Color.white.opacity(0.45)
    
    private static func lightenColor(named name: String, amount: CGFloat) -> Color {
        #if canImport(UIKit)
        if let uiColor = UIColor(named: name) {
            return Color(uiColor.lightened(by: amount))
        }
        #endif
        return Color(name)
    }
}

#if canImport(UIKit)
fileprivate extension UIColor {
    func lightened(by amount: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return self
        }

        let adjust = { (component: CGFloat) in
            min(component + (1 - component) * amount, 1)
        }

        return UIColor(red: adjust(red), green: adjust(green), blue: adjust(blue), alpha: alpha)
    }
}
#endif

