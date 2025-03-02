//
//  SettingsController.swift
//  TaskFlow
//
//  Created by Данил Забинский on 27.02.2025.
//

import UIKit

final class SettingsController: UIViewController {
    
    private var settingsViewModel: SettingsViewModel!
    
    init(settingsViewModel: SettingsViewModel!) {
        self.settingsViewModel = settingsViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var settingsView: SettingsView {
        view as! SettingsView
    }
    
    override func loadView() {
        view = SettingsView(viewModel: settingsViewModel)
    }
    
    override func viewDidLoad() {
        
        settingsViewModel.reloadCollectionView = { [weak self] in
            self?.settingsView.reloadColorsCollectionView()
        }
        
        settingsViewModel.dismiss = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}
