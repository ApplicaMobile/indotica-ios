//
//  ViewController.swift
//  Indotica
//
//  Created by Nicolas Llanos on 16/01/2024.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var loginWithQrButton: UIButton!

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
}
