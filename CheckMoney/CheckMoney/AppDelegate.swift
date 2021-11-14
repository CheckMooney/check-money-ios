//
//  AppDelegate.swift
//  CheckMoney
//
//  Created by SeungYeon Kim on 2021/10/21.
//

import UIKit
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    /*
     AppDelegate는 Process LifeCycle, Session LifeCycle 을 관리함
     1. 앱의 주요 데이터 구조를 초기화
     2. 앱의 scene을 설정
     3. 앱 밖에서 발생한 알림(ex. 배터리 부족, 다운로드 완료 등)에 대응
     */
    
    var googleSignInConfig: GIDConfiguration?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // 애플리케이션이 실행된 직후 사용자의 화면에 보여지기 직전에 호출
        
        googleSignInConfig = GIDConfiguration.init(
            clientID: "500159069581-el3csr571ui6mi1jugnqhicvfv61u17g.apps.googleusercontent.com",
            serverClientID: "500159069581-m2dqev5jhbpumksnoodl7bmi90v5kjtl.apps.googleusercontent.com")
        
        GIDSignIn.sharedInstance.restorePreviousSignIn(callback: { user, error in
            if error != nil || user == nil {
                // Show the app's signed-out state.
            } else {
                // Show the app's signed-in state.
            }
        })
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // custom scheme을 포함하는 URL을 오픈할 때, 해당 메소드를 실행하여 URL을 앱으로 전달
        
        let handled = GIDSignIn.sharedInstance.handle(url)
        if (handled) {
            print("open url : \(options)")
            return true
        }
        
        return false
    }
    
    
}

