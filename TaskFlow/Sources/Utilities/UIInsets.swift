//
//  ScreenSize.swift
//  TaskFlow
//
//  Created by Данил Забинский on 05.02.2025.
//

import UIKit

struct UIInsets {
    static var topInset: CGFloat {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?
            .windows
            .first(where: { $0.isKeyWindow }) else {
            return 0
        }
        return window.safeAreaInsets.top
    }
    
    static var bottomInset: CGFloat {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?
            .windows
            .first(where: { $0.isKeyWindow }) else {
            return 0
        }
        return window.safeAreaInsets.bottom
    }
}
