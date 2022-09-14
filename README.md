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
