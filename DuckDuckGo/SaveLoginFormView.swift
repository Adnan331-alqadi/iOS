//
//  SaveLoginFormView.swift
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

struct SaveLoginFormView: View {
    @ObservedObject var loginViewModel: SaveLoginViewModel
    private let cellHeight: CGFloat = 35

    var body: some View {
        VStack {
            SaveLoginWebsiteCell(text: loginViewModel.website,
                                 image: Image(uiImage: loginViewModel.faviconImage),
                                 disabled: loginViewModel.state == .update)
                .frame(height: cellHeight)
            
            Divider()
            
            SaveLoginUsernameCell(username: $loginViewModel.username, disabled: loginViewModel.state == .update)
                .frame(height: cellHeight)

            Divider()
            
            SaveLoginPasswordCell(password: $loginViewModel.password)
                .frame(height: cellHeight)
        }
    }
}

struct SaveLoginFormView_Previews: PreviewProvider {
    static var previews: some View {
        SaveLoginFormView(loginViewModel: SaveLoginViewModel.preview)
    }
}