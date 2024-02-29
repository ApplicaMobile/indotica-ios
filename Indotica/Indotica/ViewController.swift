//
//  ViewController.swift
//  Indotica
//
//  Created by Nicolas Llanos on 16/01/2024.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var loginWithQrButton: UIButton!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var alert: UIAlertController?
    var token: String?
    private var borderView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupScanning() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            failed()
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                failed()
                return
            }
        } catch {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(previewLayer)
    }
    
    
    @IBAction func loginWithQrButtonAction(_ sender: Any) {
        setupScanning()
        captureSession.startRunning()
    }
    
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            getData(code: stringValue)
            getToken()
        }
    }
    
    private func getToken() {
        let req = TokenRequest(token: token ?? "")
        TokenService.shared.getToken(data: req) { res, err in
            if let _ = err { return }
            if let res = res {
                UserDefaultsManager.shared.userToken = res.notification?.token ?? ""
                print("info obtenida")
                print(res)
            }
        }
    }
    
    func getData(code: String) {
        token = code
        alert = UIAlertController(title: "QR Code", message: code, preferredStyle: .alert)
        alert?.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.captureSession.startRunning()
            self.alert?.dismiss(animated: true, completion: nil)
        }))
        present(alert ?? UIAlertController(), animated: true)
    }
}
