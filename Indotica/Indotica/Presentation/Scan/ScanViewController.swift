//
//  ScanViewController.swift
//  Indotica
//
//  Created by Nicolas Llanos on 01/03/2024.
//

import UIKit
import AVFoundation
import Combine

class ScanViewController: BaseViewController {
    
    private var captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var qrCodeFrameView: UIView?
    private var scannedQRData: String?
    
    @Injected(\.loginViewModelProvider) var loginViewModel: LoginViewModel
    private var disposables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setObservers()
        setupCamera()
    }
    
    private func setObservers() {
        observeSpinner()
        observeLoginSuccess()
    }
    
    private func observeSpinner() {
        loginViewModel.$spinner
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] spinner in
                if spinner {
                    self?.showSpinner()
                } else {
                    self?.hideSpinner()
                }
            })
            .store(in: &disposables)
    }
    
    private func observeLoginSuccess() {
        loginViewModel.$loginSuccessFull
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] loginSuccessFull in
                if loginSuccessFull {
                    self?.goToHomeScreen()
                }
            })
            .store(in: &disposables)
    }
    
    private func goToHomeScreen() {
        //TODO: go to home ?
        print("Login successfull, now go to home")
    }
}

extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [.qr]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            
            let screenSize = UIScreen.main.bounds.size
            let scanRectSize = CGSize(width: screenSize.width * 0.8, height: screenSize.width * 0.8)
            let scanRect = CGRect(x: (screenSize.width - scanRectSize.width) / 2, y: (screenSize.height - scanRectSize.height) / 2, width: scanRectSize.width, height: scanRectSize.height)
            videoPreviewLayer?.frame = scanRect
            
            view.layer.addSublayer(videoPreviewLayer!)
            
            captureSession.startRunning()
            qrCodeFrameView = UIView()
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.gray.cgColor
                qrCodeFrameView.layer.borderWidth = 10
                qrCodeFrameView.layer.opacity = 0.6
                
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
        } catch {
            print(error)
            return
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else {
                return
            }
            guard let stringValue = readableObject.stringValue else {
                return
            }
            loginViewModel.login(token: stringValue)
            print("*** \(stringValue)")
        }
    }
}
