//
//  AutofillLoginPromptViewController.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import SwiftUI
import BrowserServicesKit

@available(iOS 14.0, *)
protocol AutofillLoginPromptViewControllerExpansionResponseDelegate: AnyObject {
    func autofillLoginPromptViewController(_ viewController: AutofillLoginPromptViewController, isExpanded: Bool)
}

@available(iOS 14.0, *)
class AutofillLoginPromptViewController: UIViewController {
    
    weak var expansionResponseDelegate: AutofillLoginPromptViewControllerExpansionResponseDelegate?
    let completion: ((SecureVaultModels.WebsiteAccount?) -> Void)?
    
    private let accounts: [SecureVaultModels.WebsiteAccount]
    
    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()
    
    private lazy var expandedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "AutofillPromptLargeBackground")
        return view
    }()

    internal init(accounts: [SecureVaultModels.WebsiteAccount], completion: ((SecureVaultModels.WebsiteAccount?) -> Void)? = nil) {
        self.accounts = accounts
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.clear
        view.addSubview(blurView)
        view.addSubview(expandedBackgroundView)
        expandedBackgroundView.alpha = isExpanded ? 1 : 0
        
        let viewModel = AutofillLoginPromptViewModel(accounts: accounts, isExpanded: isExpanded)
        guard let viewModel = viewModel else {
            return
        }
        
        viewModel.delegate = self
        expansionResponseDelegate = viewModel
        
        let view = AutofillLoginPromptView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = .clear
        presentationController?.delegate = self
        installChildViewController(controller)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blurView.frame = self.view.frame
        expandedBackgroundView.frame = self.view.frame
    }
    
    private var isExpanded: Bool {
        if #available(iOS 15.0, *),
           let presentationController = presentationController as? UISheetPresentationController {
            if presentationController.selectedDetentIdentifier == nil &&
                presentationController.detents.contains(.medium()) {
                return false
            } else if presentationController.selectedDetentIdentifier == .medium {
                return false
            }
        }
        return true
    }
}

@available(iOS 14.0, *)
extension AutofillLoginPromptViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        completion?(nil)
        //TODO Need to make sure this is called in all dismiss cases
    }
    
    @available(iOS 15.0, *)
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        UIView.animate(withDuration: 0.2) {
            self.expandedBackgroundView.alpha = self.isExpanded ? 1 : 0
        }
        expansionResponseDelegate?.autofillLoginPromptViewController(self, isExpanded: isExpanded)
    }
}

@available(iOS 14.0, *)
extension AutofillLoginPromptViewController: AutofillLoginPromptViewModelDelegate {
    func autofillLoginPromptViewModel(_ viewModel: AutofillLoginPromptViewModel, didSelectAccount account: SecureVaultModels.WebsiteAccount) {
        completion?(account)
        dismiss(animated: true, completion: nil)
    }
    
    func autofillLoginPromptViewModelDidCancel(_ viewModel: AutofillLoginPromptViewModel) {
        completion?(nil)
        dismiss(animated: true, completion: nil)
    }
    
    func autofillLoginPromptViewModelDidRequestExpansion(_ viewModel: AutofillLoginPromptViewModel) {
        if #available(iOS 15.0, *) {
            if let presentationController = presentationController as? UISheetPresentationController {
                presentationController.animateChanges {
                    presentationController.selectedDetentIdentifier = .large
                    expandedBackgroundView.alpha = 1
                }
                expansionResponseDelegate?.autofillLoginPromptViewController(self, isExpanded: true)
            }
        }
    }
}