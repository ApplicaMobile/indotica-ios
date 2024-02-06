//
//  ViewController.swift
//  Indotica
//
//  Created by Nicolas Llanos on 16/01/2024.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var loginWithQrButton: UIButton!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        loginWithQrButton.layer.borderWidth = 3.0
        loginWithQrButton.layer.cornerRadius = 15.0
        loginWithQrButton.layer.borderColor = UIColor.black.cgColor
    }

    @IBAction func loginWithQrButtonAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self

            present(imagePicker, animated: true, completion: nil)
        } else {
            print("El dispositivo no tiene cámara.")
        }
    }

    @objc func backButtonAction() {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func setupCamera() {
        captureSession = AVCaptureSession()

        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("No se encontró una cámara disponible")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print("Error al configurar la entrada de la cámara: \(error.localizedDescription)")
            return
        }

        let output = AVCaptureMetadataOutput()
        captureSession.addOutput(output)

        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.qr]

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let qrCodeValue = metadataObject.stringValue else {
            print("No se pudo obtener el valor del código QR")
            return
        }
        print("Código QR escaneado: \(qrCodeValue)")

        // Aquí puedes realizar las acciones necesarias con el valor del código QR

        captureSession.stopRunning()
        previewLayer.removeFromSuperlayer()
    }
}
