//
//  CustomHeightPresentationController.swift
//  TaskFlow
//
//  Created by Данил Забинский on 11.03.2025.
//

import UIKit

final class CustomHeightPresentationController: UIPresentationController {
    
    var dismissView: (() -> Void)?
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.35)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        return view
    }()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let height = UIScreen.main.bounds.height / 2.5
        
        return CGRect(x: 0,
                      y: containerView.bounds.height - height,
                      width: containerView.bounds.width,
                      height: height)
    }
    
    override func presentationTransitionWillBegin() {
        setup()
        
        bgView.alpha = 0
        UIView.animate(withDuration: 0.3) { self.bgView.alpha = 1 }
    }
    
    override func dismissalTransitionWillBegin() {
        UIView.animate(withDuration: 0.3) { self.bgView.alpha = 0 }
        completion: { _ in
            self.bgView.removeFromSuperview()
        }
    }
}

private extension CustomHeightPresentationController {
    
    func setup() {
        setupSubviews()
        setupLayout()
    }
    
    func setupSubviews() {
        containerView?.addSubview(bgView)
    }
    
    func setupLayout() {
        guard let containerView = containerView else { return }
        
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: containerView.topAnchor),
            bgView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }
    
    @objc func dismiss() { dismissView?() }
}
