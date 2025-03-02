//
//  KeyboardObserver.swift
//  TaskFlow
//
//  Created by Данил Забинский on 11.02.2025.
//

import UIKit

class KeyboardObserver {
    
    private var onShowHandler: ((_ keyboardFrame: CGRect) -> Void)?
    private var onHideHandler: (() -> Void)?
    var isKeyboardEnabled: Bool
    
    init(onShow: @escaping (_ keyboardFrame: CGRect) -> Void,
         onHide: @escaping () -> Void) {
        self.onShowHandler = onShow
        self.onHideHandler = onHide
        self.isKeyboardEnabled = false
        startObserver()
    }
    
    private func startObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc private func handleKeyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        self.isKeyboardEnabled = true
        self.onShowHandler?(keyboardFrame)
    }
    
    @objc private func handleKeyboardWillHide(notification: Notification) {
        self.isKeyboardEnabled = false
        self.onHideHandler?()
    }
    
    func stopObserving() {
        NotificationCenter.default.removeObserver(self)
        onShowHandler = nil
        onHideHandler = nil
    }
}

protocol KeyboardObservable: AnyObject {
    
    var keyboardObserver: KeyboardObserver? { get set }
    func startKeyboardObservering(onShow: @escaping (_ keyboardFrame: CGRect) -> Void,
                                  onHide: @escaping () -> Void)
    func stopKeyboardObservering()
}

extension KeyboardObservable {
    
    func startKeyboardObservering(onShow: @escaping (_ keyboardFrame: CGRect) -> Void,
                                  onHide: @escaping () -> Void) {
        keyboardObserver = KeyboardObserver(onShow: onShow, onHide: onHide) 
    }
    
    func stopKeyboardObservering() {
        keyboardObserver?.stopObserving()
    }
}
