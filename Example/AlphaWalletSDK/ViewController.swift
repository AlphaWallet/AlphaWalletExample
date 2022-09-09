//
//  ViewController.swift
//  AlphaWalletSDK
//
//  Created by vladyslav-iosdev on 09/07/2022.
//  Copyright (c) 2022 vladyslav-iosdev. All rights reserved.
//

import UIKit
import AlphaWalletSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let wallet = Wallet(address: Constants.nullAddress, origin: .hd)
        let store = JsonWalletAddressesStore()
        let analytics = AnalyticsService()
        let storage = try! KeychainStorage(keyPrefix: "test-app")
        let keystore = EtherKeystore(keychain: storage, walletAddressesStore: store, analytics: analytics)
        guard let message = "Hello world".data(using: .utf8) else { return }

        switch keystore.signMessage(message, for: wallet.address, prompt: "sing message") {
        case .success(let data):
            break
        case .failure(let error):
            break
        }
    }
}

