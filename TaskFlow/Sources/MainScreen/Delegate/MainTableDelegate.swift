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
    
    var reloadHeaders: (() -> Void)?
    var createdTodo: Todo? {
        didSet {
            if let createdTodo { onTodoCreate?(createdTodo) }
        }
    }
    var onTodoCreate: ((Todo) -> Void)?
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            if mainViewModel.tableState == .addingTask {
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
        mainViewModel.calculateCellsHeight(at: indexPath)
    }
    
    func updateHeadersBackgroundColor() {
        soonerSectionHeader.updateColor()
        laterSectionHeader.updateColor()
    }
    
    func updateHeaderCount(in section: MainTableSections) {
        getHeaderIn(section: section).setUpdatedTodosCount(mainViewModel.getTodos(in: section).count)
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
    
    func setupBindings() {
        
        addingTodoHeader.onTodoCreate = { [weak self] todo in
            self?.onTodoCreate?(todo)
            self?.reloadHeaders?()
        }
        
        addingTodoHeader.hideView = { [weak self] in
            self?.reloadHeaders?()
        }
    }
    
    func setupScrollView() {
        
        soonerSectionHeader.mainScrollView.alwaysBounceVertical = false
        laterSectionHeader.mainScrollView.delegate = self
    }
    
    func setupHeaderActions() {
        
        soonerSectionHeader.addActionToUpOrDownButton(setHeaderAction(section: .sooner))
        laterSectionHeader.addActionToUpOrDownButton(setHeaderAction(section: .later))
    }
    
    func setHeaderAction(section: MainTableSections) -> UIAction {
        return UIAction { [weak self] _ in guard let self else { return }
            let currentHeader = (section == .sooner) ? soonerSectionHeader : laterSectionHeader
            mainViewModel.handleHeaderButtonTapped(for: section, isHalfScreen: currentHeader.isHalfScreen)
            currentHeader.isHalfScreen.toggle()
        }
    }
    
    func getHeaderIn(section: MainTableSections) -> MainTableHeaderView {
        (section == .sooner) ? soonerSectionHeader : laterSectionHeader
    }
}

// MARK: Scroll View Delegate methods
extension MainTableDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = mainViewModel.controllScrollingValue(scrollView.contentOffset.y)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let didSecitonChanged = mainViewModel.changeStateAccordingToDragging(scrolledValue: scrollView.contentOffset.y)
        if didSecitonChanged {
            switch mainViewModel.tableState {
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
