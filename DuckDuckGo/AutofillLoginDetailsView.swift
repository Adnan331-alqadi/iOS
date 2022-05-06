//
//  AutofillLoginDetailsView.swift
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

import SwiftUI
import DuckUI

@available(iOS 14.0, *)
struct AutofillLoginDetailsView: View {
    @ObservedObject var viewModel: AutofillLoginDetailsViewModel
    @State private var cellMaxWidth: CGFloat?

    var body: some View {
        Group {
            switch viewModel.viewMode {
            case .edit:
                editModeContentView
            case .view:
                viewModeContentView
            }
        }.transition(.opacity)
    }
    
    private var editModeContentView: some View {
        List {
            Section {
                editableCell("Login Name", subtitle: $viewModel.title)
            }
    
            Section {
                editableCell("Username", subtitle: $viewModel.username)
                editableCell("Password", subtitle: $viewModel.password, secure: true)
            }
            
            Section {
                editableCell("Address", subtitle: $viewModel.address)
            }
            
            Section {
                editableCell("Notes", subtitle: $viewModel.username)
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var viewModeContentView: some View {
        List {
            Section {
                ImageTitleSubtitleListItemView(viewModel: viewModel.headerViewModel)
            }
            
            Section {
                copyableCell("Username", subtitle: viewModel.username) {
                    viewModel.copyToPasteboard(.username)
                }
                
                secureCopyableCell("Password", subtitle: $viewModel.password) {
                    viewModel.copyToPasteboard(.password)
                }
            }
            
            Section {
                copyableCell("Address", subtitle: viewModel.address) {
                    viewModel.copyToPasteboard(.address)
                }
            }
            
            Section {
                editableCell("Notes", subtitle: $viewModel.username)
                    .disabled(true)
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func editableCell(_ title: String, subtitle: Binding<String>, secure: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .label3AltStyle()
            
            HStack {
                if secure {
                    SecureField("", text: subtitle)
                        .label4Style()
                } else {
                    ClearTextField(text: subtitle)
                        .label4Style()
                }
            }
        }.frame(height: 60)
    }
    
    private func copyableCell(_ title: String, subtitle: String, menuAction: @escaping () -> Void) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .label3AltStyle()
                    .disabled(true)
                
                HStack {
                    Text(subtitle)
                        .label4Style()
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .menuController("Copy \(title)", action: menuAction)
    }
    
    #warning("refactor this pasta")
    private func secureCopyableCell(_ title: String, subtitle: Binding<String>, menuAction: @escaping () -> Void) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .label3AltStyle()
                    .disabled(true)
                
                HStack {
                    SecureField("", text: subtitle)
                        .label4Style()
                        .disabled(true)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .menuController("Copy \(title)", action: menuAction)
    }
}

struct ClearTextField: View {
    @Binding var text: String
    @State private var closeButtonVisible = false
    
    var body: some View {
        HStack {
            TextField("", text: $text) { editing in
                closeButtonVisible = editing
            } onCommit: {
                closeButtonVisible = false
            }
            Spacer()
            Image(systemName: "multiply.circle.fill")
                .foregroundColor(.secondary)
                .opacity(closeButtonOpacity)
                .onTapGesture { self.text = "" }
        }
    }
    
    private var closeButtonOpacity: Double {
        if text == "" || !closeButtonVisible {
            return 0
        }
        return 1
    }
}

#warning("Fix preview with protocol")
//@available(iOS 14.0, *)
//struct AutofillLoginDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AutofillLoginDetailsView()
//    }
//}