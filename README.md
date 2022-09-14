# AlphaWalletSDK

[![CI Status](https://img.shields.io/travis/vladyslav-iosdev/AlphaWalletSDK.svg?style=flat)](https://travis-ci.org/vladyslav-iosdev/AlphaWalletSDK)
[![Version](https://img.shields.io/cocoapods/v/AlphaWalletSDK.svg?style=flat)](https://cocoapods.org/pods/AlphaWalletSDK)
[![License](https://img.shields.io/cocoapods/l/AlphaWalletSDK.svg?style=flat)](https://cocoapods.org/pods/AlphaWalletSDK)
[![Platform](https://img.shields.io/cocoapods/p/AlphaWalletSDK.svg?style=flat)](https://cocoapods.org/pods/AlphaWalletSDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

platform: **iOS**, minimum deployment version: **13.0**

## Installation

AlphaWalletSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AlphaWalletSDK'
```
Also make sure pod file has right link for `AlphaWalletWeb3Provider`
```
pod 'AlphaWalletWeb3Provider', :git=>'https://github.com/AlphaWallet/AlphaWallet-web3-provider', :commit => '9a4496d02b7ddb2f6307fd0510d8d7c9fcef9870'
```

### Replace API Keys

## Credentials:

For updating credentials for services like `Infura`, `Etherscan` use `.credentials` file placed in `SOURCE_ROOT` root directory of your project.
Update `.credentials` file with key value pairs separated with `=`.

```
INFURAKEY=<YOUR INFURA API KEY>
ETHERSCANKEY=
BINANCESMARTCHAINEXPLORERAPIKEY=
POLYGONSCANEXPLORERAPIKEY=
OPENSEAKEY=
COINBASEAPPID=
COVALENTAPIKEY=
KLAYTNRPCNODEKEYBASICAUTH=
```

The list of available credential keys listed below:

- INFURAKEY
- ETHERSCANKEY
- BINANCESMARTCHAINEXPLORERAPIKEY
- POLYGONSCANEXPLORERAPIKEY
- OPENSEAKEY
- RAMPAPIKEY
- COINBASEAPPID
- ENJINUSERNAME
- ENJINUSERPASSWORD
- WALLETCONNECTPROJECTID
- UNSTOPPABLEDOMAINSV2KEY
- BLOCKSCHATPROXYKEY
- COVALENTAPIKEY
- KLAYTNRPCNODEKEYBASICAUTH

AlphaWalletSDK provides access to core features of Wallet app including:
- Key managment
<!-- TokenScript --> 
- Activities and transactions
- Tokens
- ENS resolving
- Blockies generation 

## Key managment
Key managment features perform defined in `Keystore` protocol, with its implementation `EtherKeystore`. 
Keystore creates using:
```
private lazy var keystore: Keystore = {
    let store = JsonWalletAddressesStore()
    let storage = try! KeychainStorage(keyPrefix: "<test-app>")
    return EtherKeystore(keychain: storage, walletAddressesStore: store, analytics: analytics)
}()
```
A new wallet could be generated, imported using seed phrase or private key:
```
let wallet: Wallet = try keystore.createAccount().get()

```

To import already created wallet use keystore's function `importWallet(type: )`, callback closure returns `result` of `Wallet` instance for succesfully import.
```
struct TestKeyStore {
    static let keystore: String = "{\"address\":\"5e9c27156a612a2d516c74c7a80af107856f8539\",\"crypto\":{\"cipher\":\"aes-128-ctr\",\"ciphertext\":\"5eb0c790d1fb27824c78acac9233241b340c329b46aba08c6533b70ab67ea74f\",\"cipherparams\":{\"iv\":\"e5ab559977af075eda00a97c8f0ce506\"},\"kdf\":\"scrypt\",\"kdfparams\":{\"dklen\":32,\"n\":4096,\"p\":6,\"r\":8,\"salt\":\"b43142f34caf2b3b39c16f52344701f800711589f799cdae1827ac2f844f9602\"},\"mac\":\"c6ccaecca7896974dacac91a8116216ec287930bc74bfd7694a94f08bd992095\"},\"id\":\"e3554f73-4d0a-40a0-b721-fc801623d5ba\",\"version\":3}"
    static let password: String = "test"
    static let newPassword: String = "test123"
    static let testPrivateKey = "9cdb5cab19aec3bd0fcd614c5f185e7a1d97634d4225730eba22497dc89a716c"
}

keystore.importWallet(type: .keystore(string: TestKeyStore.keystore, password: TestKeyStore.password)) { result in
    guard let wallet = try? result.get() else { return }
}
```

Message signing could be performed using next construction:
```
guard let message: Data = "Hello AlphaWallet".data(using: .utf8) else { return }
let signature: Data = try keystore.signMessage(message, for: wallet.address, prompt: "Sign Message").get()
```
For verifying signed message could be used the next instruction:
```
switch Web3.Utils.ecrecover(message: message, signature: signature) {
case .success(let address):
    assert(wallet.address.sameContract(as: address))
case .failure(let error):
    print(error)
}
```
To export seed phrase of HDWallet use keystore's function `exportSeedPhraseOfHdWallet`, callback closure returns `result` for retrieved seed phrase.
```
keystore.exportSeedPhraseOfHdWallet(forAccount: wallet, context: .init(), prompt: "Accessing your wallet seed phrase to back it up") { result in
    guard let seedPhrase = try? result.get().split(separator: " ") else { return }
}
```

<!-- ## TokenScript -->
 
## Activities and transactions

## Tokens
  AlphaWallet uses pipeline stack for generating token collection, includes next services:
  - TokenScript - applies overrides from token script file;
  - TokenBalance - updates token with its actual balance, (via smart contract call);
  - CoinTicker - updates token with its resolved ticker, (Retrieved via CoinGecko).
`TokensProcessingPipeline` - describes public interface of tokens pipeline, `WalletDataProcessingPipeline` its default implementation, public as well to being able to be overriden. AlphaWallet use `Realm` database as local storage. Pipeline supports storage override.

## CoinTickers
For determining latest token prices and price charts AlphaWallet use CoinGecko service. Its uses storing charts in local storage for short time, to avoid (403) Error. `CoinTickersFetcher` is public interface for coinTickerResolver, and its implementation `CoinGeckoTickersFetcher`. Some of app services (e.g TokensPipeline) have dependency from `CoinTickersFetcher`, also can be overriden with your own implementation.

## ENS resolving
For resolving ENS domains we are using contract call methods also we support for UnstoppableDomains domains v2. All calls perform via instance of `DomainResolutionServiceType` type. `DomainResolutionService` its default implementation. All interfaces are public to being able to implement its own implementation. We cache resolved ens domains in local `Realm` storage. AlphaWallet suppports retrieving ENS records, e.g [eip-634](https://eips.ethereum.org/EIPS/eip-634) to get values for keys:
```
public enum EnsTextRecordKey: Equatable, Hashable {
    /// A URL to an image used as an avatar or logo
    case avatar
    /// A description of the name
    case description
    /// A canonical display name for the ENS name; this MUST match the ENS name when its case is folded, and clients should ignore this value if it does not (e.g. "ricmoo.eth" could set this to "RicMoo.eth")
    case display
    /// An e-mail address
    case email
    /// A list of comma-separated keywords, ordered by most significant first; clients that interpresent this field may choose a threshold beyond which to ignore
    case keywords
    /// A physical mailing address
    case mail
    /// A notice regarding this name
    case notice
    /// A generic location (e.g. "Toronto, Canada")
    case location
    /// A phone number as an E.164 string
    case phone
    /// A website URL
    case url
    case custom(String)
}
```
## Blockies generation 
AlphaWallet support Blockie (wallet image) generation, auto generated icon image, and retrieving image from ENS records (for `avatar`)

## Author

oa-s, krypto.pank@gmail.com

## License

AlphaWalletSDK is available under the MIT license. See the LICENSE file for more info.
