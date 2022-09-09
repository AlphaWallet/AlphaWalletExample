//
//  AnalyticsService.swift
//  AlphaWalletFoundation_Example
//
//  Created by Vladyslav Shepitko on 06.09.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import AlphaWalletFoundation

public final class AnalyticsService: NSObject, AnalyticsServiceType {

    public func applicationDidBecomeActive() {

    }

    public func application(continue userActivity: NSUserActivity) {

    }

    public func application(open url: URL, sourceApplication: String?, annotation: Any) {

    }

    public func application(open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) {

    }

    public func application(didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {

    }

    public func log(navigation: AnalyticsNavigation, properties: [String: AnalyticsEventPropertyValue]?) {

    }

    public func log(action: AnalyticsAction, properties: [String: AnalyticsEventPropertyValue]?) {

    }

    public func log(stat: AnalyticsStat, properties: [String: AnalyticsEventPropertyValue]?) {

    }

    public func log(error: AnalyticsError, properties: [String: AnalyticsEventPropertyValue]?) {

    }

    public func setUser(property: AnalyticsUserProperty, value: AnalyticsEventPropertyValue) {

    }

    public func incrementUser(property: AnalyticsUserProperty, by value: Int) {

    }

    public func incrementUser(property: AnalyticsUserProperty, by value: Double) {

    }
}
