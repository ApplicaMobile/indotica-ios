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
    private var borderView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupScanning() {
        // Crear una sesión de captura
        captureSession = AVCaptureSession()
        
        // Obtener el dispositivo de captura de video predeterminado
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            failed()
            return
        }
        
        // Crear un objeto de entrada de video con el dispositivo de captura
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            // Agregar la entrada de video a la sesión de captura
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
        
        // Crear un objeto de salida de metadatos
        let metadataOutput = AVCaptureMetadataOutput()
        
        // Agregar la salida de metadatos a la sesión de captura
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            // Configurar el delegado y los tipos de objetos de metadatos
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        // Configurar la vista previa de video
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        // Agregar la vista previa de video a la vista actual
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
        }
    }
    
    func getData(code: String) {
        alert = UIAlertController(title: "QR Code", message: code, preferredStyle: .alert)
        alert?.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.captureSession.startRunning()
            self.alert?.dismiss(animated: true, completion: nil)
        }))
        present(alert ?? UIAlertController(), animated: true)
    }
}
