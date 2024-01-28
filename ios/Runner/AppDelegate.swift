import UIKit
import Flutter
import Vision

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let ocrChannel = FlutterMethodChannel(name: "flutter.poc.ocr",
                                              binaryMessenger: controller.binaryMessenger)
        
        ocrChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // This method is invoked on the UI thread.
            switch call.method {
            case "getText":
                let imagePath = call.arguments as! String
                self?.recognizeTextFromPath(imagePath, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func recognizeTextFromPath(_ imagePath: String, result: @escaping FlutterResult) {
        guard let cgImage = UIImage(contentsOfFile: imagePath)?.cgImage else {
            let error = FlutterError(code: "IMAGE_NOT_FOUND", message: "Image not found at path", details: nil)
            result(error)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                //
                result(FlutterError(code: "TEXT_RECOGNITION_FAILED", message: "Text recognition failed", details: nil))
                return
            }
            var recognizedText = ""
            for observation in observations {
                for text in observation.topCandidates(1) {
                    recognizedText += text.string + "\n"
                }
            }
            
            result(recognizedText)
        }
        request.recognitionLanguages = ["th-TH","en-US"]
        request.usesLanguageCorrection = true
        do {
            try requestHandler.perform([request])
        } catch {
            result(FlutterError(code: "REQUEST_FAILED", message: "Text recognition request failed", details: nil))
        }
    }
}
