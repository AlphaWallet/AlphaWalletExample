//
//  ViewController.swift
//  AlphaWalletSDK
//
//  Created by vladyslav-iosdev on 09/07/2022.
//  Copyright (c) 2022 vladyslav-iosdev. All rights reserved.
//

import UIKit
import AlphaWalletSDK
import Combine

class ViewController: UIViewController {

    private lazy var tokensPipeline: TokensProcessingPipeline = {
        let eventsDataStore = NonActivityMultiChainEventsDataStore(store: .storage(for: wallet))
        let assetDefinitionStore = AssetDefinitionStore()
        let analytics = AnalyticsService()

        let coinTickersFetcher: CoinTickersFetcher = CoinGeckoTickersFetcher()
        let config = Config()
        let tokensDataStore = MultipleChainsTokensDataStore(store: .storage(for: wallet), servers: [server])
        let transactionsStorage: TransactionDataStore = .init(store: .storage(for: wallet))
        let sessionProvider = SessionsProvider(config: config, analytics: analytics)

        let importToken = ImportToken(sessionProvider: sessionProvider, wallet: wallet, tokensDataStore: tokensDataStore, assetDefinitionStore: assetDefinitionStore, analytics: analytics)
        let nftProvider: NFTProvider = AlphaWalletNFTProvider(analytics: analytics)
        let tokensService = AlphaWalletTokensService(sessionsProvider: sessionProvider, tokensDataStore: tokensDataStore, analytics: analytics, importToken: importToken, transactionsStorage: transactionsStorage, nftProvider: nftProvider, assetDefinitionStore: assetDefinitionStore)

        let pipeline = WalletDataProcessingPipeline(wallet: wallet, tokensService: tokensService, coinTickersFetcher: coinTickersFetcher, assetDefinitionStore: assetDefinitionStore, eventsDataStore: eventsDataStore)

        sessionProvider.start(wallet: wallet)
        pipeline.start()

        return pipeline
    }()
    private let server: RPCServer = .main
    private let wallet: Wallet = Wallet(address: Constants.nullAddress, origin: .hd)
    private let analytics = AnalyticsService()

    private lazy var keystore: Keystore = {
        let store = JsonWalletAddressesStore()
        let storage = try! KeychainStorage(keyPrefix: "test-app")
        return EtherKeystore(keychain: storage, walletAddressesStore: store, analytics: analytics)
    }()
    private var cancelable: Set<AnyCancellable> = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let wallet = try? keystore.createAccount().get() else { return }
        signMessage(wallet: wallet)
        verifySignature(wallet: wallet)
        exportHdWalletToSeedPhrase(wallet: wallet)

        tokensPipeline.tokenViewModels.sink { tokens in
            print("tokens for wallet: \(self.wallet)")
        }.store(in: &cancelable)
    }

    private func verifySignature(wallet: Wallet) {
        guard let message: Data = "Hello AlphaWallet".data(using: .utf8) else { return }
        guard let signature: Data = try? keystore.signMessage(message, for: wallet.address, prompt: "Sign Message").get() else { return }

        switch Web3.Utils.ecrecover(message: message, signature: signature) {
        case .success(let address):
            assert(wallet.address.sameContract(as: address))
        case .failure(let error):
            print("verify signature failure: \(error)")
        }
    }

    private func signMessage(wallet: Wallet) {
        let str = "Hello world"
        guard let message = str.data(using: .utf8) else { return }

        switch keystore.signMessage(message, for: wallet.address, prompt: "sing message") {
        case .success(let signature):
            print("signature: \(signature.hexString) for message: \(str)")
        case .failure(let error):
            print("sing message failure: \(error)")
        }
    }

    private func importWallet() {
        keystore.importWallet(type: .keystore(string: TestKeyStore.keystore, password: TestKeyStore.password)) { result in
            switch result {
            case .success(let wallet):
                print("import wallet \(wallet) succesfull")
            case .failure(let error):
                print("import wallet failure with: \(error)")
            }
            guard let wallet = try? result.get() else { return }
            print("imported wallet: \(wallet)")
        }
    }

    private func exportHdWalletToSeedPhrase(wallet: Wallet) {
        keystore.exportSeedPhraseOfHdWallet(forAccount: wallet.address, context: .init(), prompt: "Accessing your wallet seed phrase to back it up") { result in
            switch result {
            case .success(let seedPhrase):
                print("exported seed phrase: \(seedPhrase.split(separator: " ")) for wallet: \(wallet)")
            case .failure(let error):
                print("export seed phrase failure with: \(error)")
            }
        }
    }

    struct TestKeyStore {
        static let keystore: String = "{\"address\":\"5e9c27156a612a2d516c74c7a80af107856f8539\",\"crypto\":{\"cipher\":\"aes-128-ctr\",\"ciphertext\":\"5eb0c790d1fb27824c78acac9233241b340c329b46aba08c6533b70ab67ea74f\",\"cipherparams\":{\"iv\":\"e5ab559977af075eda00a97c8f0ce506\"},\"kdf\":\"scrypt\",\"kdfparams\":{\"dklen\":32,\"n\":4096,\"p\":6,\"r\":8,\"salt\":\"b43142f34caf2b3b39c16f52344701f800711589f799cdae1827ac2f844f9602\"},\"mac\":\"c6ccaecca7896974dacac91a8116216ec287930bc74bfd7694a94f08bd992095\"},\"id\":\"e3554f73-4d0a-40a0-b721-fc801623d5ba\",\"version\":3}"
        static let password: String = "test"
        static let newPassword: String = "test123"
        static let testPrivateKey = "9cdb5cab19aec3bd0fcd614c5f185e7a1d97634d4225730eba22497dc89a716c"
    }
}

