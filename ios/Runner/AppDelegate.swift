import Flutter
import UIKit
import GoogleMaps



@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyBS7vyfFibnUZye3oVPwzBaEL4lw7S5iaI")
    GeneratedPluginRegistrant.register(with: self)
    // let controller = window?.rootViewController as! FlutterViewController
    //     let arChannel = FlutterMethodChannel(name: "com.example.ar_channel", binaryMessenger: controller.binaryMessenger)

    //     arChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
    //         if call.method == "showARMarkers", let arguments = call.arguments as? [[String: Any]] {
    //             self.showMarkersInAR(arguments: arguments)
    //             result(nil)
    //         } else {
    //             result(FlutterMethodNotImplemented)
    //         }
    //     }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  // private func showMarkersInAR(arguments: [[String: Any]]) {
  //       guard let rootVC = window?.rootViewController else { return }
  //       let arViewController = ARViewController()
  //       arViewController.stories = arguments
  //       rootVC.present(arViewController, animated: true, completion: nil)
  //   }
}

