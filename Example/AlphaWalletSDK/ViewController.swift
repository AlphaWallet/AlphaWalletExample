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

        let tickerIdsFetcher: TickerIdsFetcher = TickerIdsFetcherImpl(providers: [])
        let networkProvider: CoinGeckoNetworkProviderType = CoinGeckoNetworkProvider(provider: AlphaWalletProviderFactory.makeProvider())
        let coinTickersStorage: CoinTickersStorage & ChartHistoryStorage & TickerIdsStorage = RealmStore.shared
        let coinTickersFetcher: CoinTickersFetcher = CoinGeckoTickersFetcher(networkProvider: networkProvider, storage: coinTickersStorage, tickerIdsFetcher: tickerIdsFetcher)

        let config = Config()
        let tokensDataStore = MultipleChainsTokensDataStore(store: .storage(for: wallet), servers: [server])
        let transactionsStorage: TransactionDataStore = .init(store: .storage(for: wallet))
        let sessionProvider = SessionsProvider(config: config, analytics: analytics)
        sessionProvider.start(wallet: wallet)

        let importToken = ImportToken(sessionProvider: sessionProvider, wallet: wallet, tokensDataStore: tokensDataStore, assetDefinitionStore: assetDefinitionStore, analytics: analytics)
        let nftProvider: NFTProvider = AlphaWalletNFTProvider(analytics: analytics, queue: .global())
        let tokensService = AlphaWalletTokensService(sessionsProvider: sessionProvider, tokensDataStore: tokensDataStore, analytics: analytics, importToken: importToken, transactionsStorage: transactionsStorage, nftProvider: nftProvider, assetDefinitionStore: assetDefinitionStore)

        let pipeline = WalletDataProcessingPipeline(wallet: wallet, tokensService: tokensService, coinTickersFetcher: coinTickersFetcher, assetDefinitionStore: assetDefinitionStore, eventsDataStore: eventsDataStore)
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

        tokensPipeline.start()
        signMessage()

        tokensPipeline.tokenViewModels.sink { tokens in

        }.store(in: &cancelable)
    }

    private func signMessage() {
        guard let message = "Hello world".data(using: .utf8) else { return }

        switch keystore.signMessage(message, for: wallet.address, prompt: "sing message") {
        case .success(let data):
            break
        case .failure(let error):
            break
        }
    }
}

