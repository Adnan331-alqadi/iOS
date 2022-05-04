//
//  AutofillLoginListViewModel.swift
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

import Foundation
import BrowserServicesKit
import UIKit

final class AutofillLoginListViewModel: ObservableObject {
    let secureVault: SecureVault
    @Published var items = [AutofillLoginListItemViewModel]()

    init() throws {
        secureVault = try SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared)
        update()
    }
    
    func update() {
        if let accounts = try? secureVault.accounts() {
            items = accounts.map { account in
                AutofillLoginListItemViewModel(account: account) { completion in
                    FaviconsHelper.loadFaviconSync(forDomain: account.domain,
                                                   usingCache: .tabs,
                                                   useFakeFavicon: true) { image, _ in
                        if let image = image {
                            completion(image)
                        } else {
                            completion(UIImage(systemName: "globle")!)
                        }
                    }
                }
            }
        }
    }
}