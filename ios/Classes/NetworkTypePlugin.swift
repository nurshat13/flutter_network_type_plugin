import Flutter
import UIKit
import CoreTelephony
import SystemConfiguration

public class NetworkTypePlugin: NSObject, FlutterPlugin {
    private let networkInfo = CTTelephonyNetworkInfo()
    private let defaultMaxRetries = 0
    private let defaultRetryDelay: TimeInterval = 1.0
    private let defaultTimeout: TimeInterval = 5.0

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_network_type_plugin", binaryMessenger: registrar.messenger())
        let instance = NetworkTypePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getNetworkType" {
            guard let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com") else {
                result("NO INTERNET")
                return
            }
            
            var flags = SCNetworkReachabilityFlags()
            if SCNetworkReachabilityGetFlags(reachability, &flags), flags.contains(.reachable), !flags.contains(.connectionRequired) {
                let args = call.arguments as? [String: Any]
                let urlStr = args?["url"] as? String
                let speedThreshold = args?["speedThreshold"] as? Double
                let maxRetries = args?["maxRetries"] as? Int ?? defaultMaxRetries
                let retryDelay = args?["retryDelay"] as? TimeInterval ?? defaultRetryDelay
                let timeout = args?["timeout"] as? TimeInterval ?? defaultTimeout
                let url = urlStr != nil ? URL(string: urlStr!) : nil

                let timeoutWorkItem = DispatchWorkItem {
                    result("3G or less") // Fallback if the process takes more than the specified timeout
                }
                DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: timeoutWorkItem)

                determineNetworkType(retryCount: 0, confirmed4G: false, url: url, speedThreshold: speedThreshold, maxRetries: maxRetries, retryDelay: retryDelay, timeoutWorkItem: timeoutWorkItem, result: result)
            } else {
                result("NO INTERNET")
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func determineNetworkType(retryCount: Int, confirmed4G: Bool, url: URL?, speedThreshold: Double?, maxRetries: Int, retryDelay: TimeInterval, timeoutWorkItem: DispatchWorkItem, result: @escaping FlutterResult) {
        var networkType = "Unknown"

        if #available(iOS 12.0, *) {
            if let radioAccessTechnologies = networkInfo.serviceCurrentRadioAccessTechnology {
                for (_, radioAccessTechnology) in radioAccessTechnologies {
                    networkType = getNetworkTypeString(radioAccessTechnology: radioAccessTechnology)
                    if networkType != "Unknown" {
                        break
                    }
                }
            }
        } else {
            if let radioAccessTechnology = networkInfo.currentRadioAccessTechnology {
                networkType = getNetworkTypeString(radioAccessTechnology: radioAccessTechnology)
            }
        }

        if networkType == "4G" {
            if let url = url, let speedThreshold = speedThreshold {
                if confirmed4G {
                    confirm4GSpeed(url: url, speedThreshold: speedThreshold, timeoutWorkItem: timeoutWorkItem, result: result)
                } else if retryCount < maxRetries {
                    DispatchQueue.global().asyncAfter(deadline: .now() + retryDelay) {
                        self.retryNetworkTypeCheck(retryCount: retryCount, confirmed4G: true, url: url, speedThreshold: speedThreshold, maxRetries: maxRetries, retryDelay: retryDelay, timeoutWorkItem: timeoutWorkItem, result: result)
                    }
                } else {
                    timeoutWorkItem.cancel()
                    result("3G or less") // Fallback if confirmation failed after retries
                }
            } else {
                result("4G") // Directly return 4G if URL and speedThreshold are not provided
            }
        } else if retryCount < maxRetries && !confirmed4G {
            DispatchQueue.global().asyncAfter(deadline: .now() + retryDelay) {
                self.retryNetworkTypeCheck(retryCount: retryCount, confirmed4G: false, url: url, speedThreshold: speedThreshold, maxRetries: maxRetries, retryDelay: retryDelay, timeoutWorkItem: timeoutWorkItem, result: result)
            }
        } else {
            if networkType == "Unknown" {
                networkType = "3G or less" // Fallback to 3G or less if network type cannot be determined
            }
            timeoutWorkItem.cancel()
            result(networkType)
        }
    }

    private func retryNetworkTypeCheck(retryCount: Int, confirmed4G: Bool, url: URL?, speedThreshold: Double?, maxRetries: Int, retryDelay: TimeInterval, timeoutWorkItem: DispatchWorkItem, result: @escaping FlutterResult) {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com") else {
            timeoutWorkItem.cancel()
            result("NO INTERNET")
            return
        }
        
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(reachability, &flags), flags.contains(.reachable), !flags.contains(.connectionRequired) {
            self.determineNetworkType(retryCount: retryCount + 1, confirmed4G: confirmed4G, url: url, speedThreshold: speedThreshold, maxRetries: maxRetries, retryDelay: retryDelay, timeoutWorkItem: timeoutWorkItem, result: result)
        } else {
            timeoutWorkItem.cancel()
            result("NO INTERNET")
        }
    }

    private func getNetworkTypeString(radioAccessTechnology: String) -> String {
        switch radioAccessTechnology {
        case CTRadioAccessTechnologyNRNSA, CTRadioAccessTechnologyNR:
            return "5G"
        case CTRadioAccessTechnologyLTE:
            return "4G"
        case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA:
            return "3G"
        case CTRadioAccessTechnologyCDMAEVDORev0, CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB, CTRadioAccessTechnologyeHRPD:
            return "3G"
        case CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyGPRS:
            return "2G"
        case CTRadioAccessTechnologyCDMA1x:
            return "2G"
        default:
            return "Unknown" // Fallback to Unknown for unrecognized network types
        }
    }

    private func confirm4GSpeed(url: URL, speedThreshold: Double, timeoutWorkItem: DispatchWorkItem, result: @escaping FlutterResult) {
        let startTime = Date()

        let speedTestTimeoutWorkItem = DispatchWorkItem {
            result("3G or less")
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 5, execute: speedTestTimeoutWorkItem)

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer { timeoutWorkItem.cancel() }
            
            if speedTestTimeoutWorkItem.isCancelled {
                return
            } else {
                speedTestTimeoutWorkItem.cancel()
            }

            guard error == nil, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                result("3G or less")
                return
            }
            
            let endTime = Date()
            let timeInterval = endTime.timeIntervalSince(startTime)
            let speedMbps = (8.0 * Double(data?.count ?? 0)) / (timeInterval * 1_000_000.0) // Convert bytes to megabits
            
            if speedMbps > speedThreshold { // Using user-defined speed threshold
                result("4G")
            } else {
                result("3G or less")
            }
        }
        task.resume()
    }
}
