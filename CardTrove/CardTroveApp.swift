import SwiftUI
import AppLovinSDK
import AppsFlyerLib

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppsFlyerLib.shared().appleAppID = "id6744907099"
        AppsFlyerLib.shared().appsFlyerDevKey = "LKTSofNbQHd84hkMk5xJWd"
        return true
    }
}

@main
struct CardTroveApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showAdPage = false
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let initConfig = ALSdkInitializationConfiguration(sdkKey: "LNR7IqQoTN_ruXr55ZWa_0SoWtyL65IFWSneUVVlGsv6RXs6idmUqtaf7AilM7UX_9NOyitGTFk_0prZ75JyhZ") { builder in
            builder.mediationProvider = ALMediationProviderMAX
        }
        ALSdk.shared().initialize(with: initConfig) { sdkConfig in
            print("AppLovin SDK initialized.")
            // 可以在这里预加载广告，例如 Interstitials
            let _ = InterstitialAdVC.shared
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if showAdPage {
                AdLaunchView()
            } else {
                MainTabView()
                    .onOpenURL { url in
                        handleIncomingURL(url)
                    }
                    .onChange(of: scenePhase) { newPhase in
                        if newPhase == .active {// 相当于 applicationDidBecomeActive 热启动
                            AppsFlyerLib.shared().start()
                        }
                    }
            }
        }
    }
    
    // 通用的URL处理方法：CardTroveApp://page?name=AppLovin
    private func handleIncomingURL(_ url: URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           queryItems.contains(where: { $0.name == "name" && $0.value == "AppLovin" }) {
            print("接收到链接: \(url.absoluteString)")
            print("queryItems: \(queryItems)")
            print("Path: \(url.path)")
            showAdPage = true
        }
    }
}
