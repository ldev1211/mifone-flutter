import UIKit
import PushKit
import Flutter
import Firebase
import flutter_callkeep
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        if(FirebaseApp.app() == nil){
            FirebaseApp.configure()
        }
        if #available(iOS 10.0, *) {
          UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        //Setup VOIP
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let checkFlagAnswerChannel = FlutterMethodChannel(name: "channel_check_flag",binaryMessenger: controller.binaryMessenger)
        checkFlagAnswerChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
              //This method is invoked on the UI thread.
            if(call.method == "check_flag_incoming"){
                let preferences = UserDefaults.standard
                let isAnswerFlag = preferences.bool(forKey: "isIncomingFlag") ?? false
                result(isAnswerFlag)
            } else if(call.method == "disable_flag_incoming"){
                UserDefaults.standard.set(false, forKey: "isIncomingFlag")
                UserDefaults.standard.set(false, forKey: "isEndCallFromPushkit")
                result(true)
            } else if(call.method == "disable_flag_end_call") {
                UserDefaults.standard.set(false, forKey: "isEndCallFromPushkit")
                result(true)
            } else if(call.method == "put_reactive_popup"){
                UserDefaults.standard.set(true, forKey: "isReactiveOnPopup")
                result(true)
            } else if(call.method == "check_flag_end_call_from_pushkit"){
                let preferences = UserDefaults.standard
                let isEndCall = preferences.bool(forKey: "isEndCallFromPushkit") ?? false
                result(isEndCall)
            } else if(call.method == "close_app"){
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                result(true)
            } else if(call.method == "show_display_callkit"){
                let id = "914abfa5-d0d6-4f05-83ee-1c0bed51f180"
                let callerName = "NAME"
                let userId = "123"
                let handle = ""
                let isVideo = false
                let data = flutter_callkeep.Data(id: id, callerName: callerName, handle: handle, hasVideo: isVideo)
                //set more data
                data.extra = ["userId": userId, "platform": "ios"]
                data.appName = "Done"
                //data.iconName = ...
                //data.....
                UserDefaults.standard.set(true, forKey: "isAnswerFlag")
//                SwiftCallKeepPlugin.sharedInstance?.displayIncomingCall(data, fromPushKit: true)
            } else if(call.method == "getTokenVoip"){
                result(UserDefaults.standard.string(forKey: "tokenVoip"))
            }
        })
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Handle updated push credentials
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print(credentials.token)
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        print("Token Voip: "+deviceToken)
        UserDefaults.standard.set(deviceToken,forKey: "tokenVoip")
        //Save deviceToken to your server
        SwiftCallKeepPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("didInvalidatePushTokenFor")
        SwiftCallKeepPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }

    // Handle incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        print("didReceiveIncomingPushWith")
        print("didReceiveIncomingPushWith2")
        print("didReceiveIncomingPushWith3")
        print("didReceiveIncomingPushWith4")
//        guard type == .voIP else { return }
        let payloadApns : [AnyHashable : Any] = payload.dictionaryPayload["aps"] as? [AnyHashable : Any] ?? [:]
        let type = payloadApns["type"] as? String ?? ""
        let callId = payloadApns["call-id"] as? String ?? ""
        let callIdInShared = UserDefaults.standard.string(forKey: "call-id-curr") ?? ""
        print(payloadApns)
        if(type == "alert"){
            let id = payloadApns["uuid"] as? String ?? "914abfa5-d0d6-4f05-83ee-1c0bed51f180"
            let callerName = payloadApns["call-name"] as? String ?? ""
            let userId = payloadApns["call-id"] as? String ?? ""
            let handle = payloadApns["handle"] as? String ?? ""
            let isVideo = payloadApns["isVideo"] as? Bool ?? false
            let data = flutter_callkeep.Data(id: id, callerName: callerName, handle: handle, hasVideo: isVideo)
            //set more data
            print("PAYLOAD NATIVE: ")
            print(payloadApns)
            data.extra = ["userId": userId, "platform": "ios"]
            data.appName = "Mifone"
            //data.iconName = ...
            //data.....
            UserDefaults.standard.set(true, forKey: "isIncomingFlag")
            SwiftCallKeepPlugin.sharedInstance?.displayIncomingCall(data, fromPushKit: true)
            return
        }
        if((UserDefaults.standard.bool(forKey: "isReactiveOnPopup") ?? false) && type == "endcall"){
            UserDefaults.standard.set(false,forKey: "isReactiveOnPopup")
            UserDefaults.standard.set(false, forKey: "isEndCallFromPushkit")
            UserDefaults.standard.set(false, forKey: "isIncomingFlag")
            return
        }
        if(type == "endcall"){
            UserDefaults.standard.set(true, forKey: "isEndCallFromPushkit")
            UserDefaults.standard.set(false,forKey: "isReactiveOnPopup")
            UserDefaults.standard.set(false, forKey: "isIncomingFlag")
            SwiftCallKeepPlugin.sharedInstance?.endAllCalls()
            return
        }
    }
}
