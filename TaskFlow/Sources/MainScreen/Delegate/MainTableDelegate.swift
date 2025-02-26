//
//  MainTableDelegate.swift
//  TaskFlow
//
//  Created by Данил Забинский on 06.02.2025.
//

import UIKit

final class MainTableDelegate: NSObject, UITableViewDelegate {
        
    private var mainViewModel: MainViewModel
    
    private var addingTodoHeader = AddingTodoView()
    private(set) var soonerSectionHeader = MainTableHeaderView(in: .sooner)
    private(set) var laterSectionHeader = MainTableHeaderView(in: .later)
    
    var currentState: TableState = .default {
        didSet {
            reloadTable?()
        }
    }
    var reloadTable: (() -> Void)?
    var reloadHeaders: (() -> Void)?
    var createdTodo: Todo? {
        didSet {
            if let createdTodo { sendCreatedTodoToController?(createdTodo) }
        }
    }
    var sendCreatedTodoToController: ((Todo) -> Void)?
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            if currentState == .addingTask {
                return addingTodoHeader
            } else {
                return soonerSectionHeader
            }
        case 1:
            return laterSectionHeader
        default:
            return nil
        }
    }
    
    init(viewModel: MainViewModel) {
        self.mainViewModel = viewModel
        super.init()
        setup()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        HeaderSize.default.value
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        mainViewModel.calculateCellsHeight(at: indexPath, withState: currentState)
    }
}

// MARK: Private Methods
private extension MainTableDelegate {
    
    func setup() {
        setupActions()
        setupBindings()
        setupScrollView()
        setupHeaderActions()
    }
    
    func setupActions() {
        
        mainViewModel.reloadButtonImage = { [weak self] section in
            self?.updateButtonImage(in: section)
        }
    }
    
    func updateButtonImage(in section: MainTableSections) {
        let currentHeader = (section == .sooner) ? soonerSectionHeader : laterSectionHeader
        if !currentHeader.isHalfScreen { currentHeader.isHalfScreen.toggle() }
    }
    
    func endEditing() {
        currentState = .default
        reloadHeaders?()
    }
    
    func setupBindings() {
        mainViewModel.tableStateOnChange = { [weak self] updatedState in
            self?.currentState = updatedState
        }
        
        addingTodoHeader.sendCreatedTodoToDelegate = { [weak self] todo in
            self?.sendCreatedTodoToController?(todo)
            self?.endEditing()
        }
        
        addingTodoHeader.hideView = { [weak self] in
            self?.endEditing()
        }
    }
    
    func setupScrollView() {
        
        soonerSectionHeader.mainScrollView.alwaysBounceVertical = false
        laterSectionHeader.mainScrollView.delegate = self
    }
    
    func setupHeaderActions() {
        
        soonerSectionHeader.addActionToUpOrDownButton(UIAction { [weak self] _ in
            guard let self else { return }
            mainViewModel.handleHeaderButtonTapped(for: .sooner, isHalfScreen: soonerSectionHeader.isHalfScreen)
            soonerSectionHeader.isHalfScreen.toggle()
        })
        
        laterSectionHeader.addActionToUpOrDownButton(UIAction { [weak self] _ in
            guard let self else { return }
            mainViewModel.handleHeaderButtonTapped(for: .later, isHalfScreen: laterSectionHeader.isHalfScreen)
            laterSectionHeader.isHalfScreen.toggle()
        })
    }
}

// MARK: Scroll View Delegate methods
extension MainTableDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = mainViewModel.controllScrollingValue(scrollView.contentOffset.y)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let didSecitonChanged = mainViewModel.changeStateAccordingToDragging(scrolledValue: scrollView.contentOffset.y,                                                                    currentState: &currentState)
        if didSecitonChanged {
            switch currentState {
            case .default:
                laterSectionHeader.isHalfScreen = true
                soonerSectionHeader.isHalfScreen = true
            case .lowerOpened:
                laterSectionHeader.isHalfScreen = false
            case .upperOpened:
                soonerSectionHeader.isHalfScreen = false
            default: break
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
}
