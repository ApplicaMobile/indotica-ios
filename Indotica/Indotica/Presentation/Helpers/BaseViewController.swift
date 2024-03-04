//
//  BaseViewController.swift
//  Indotica
//
//  Created by Juan on 10/08/2022.
//

import UIKit

class BaseViewController: UIViewController {

    private let child = SpinnerViewController()
    
    func showSpinner() {
        // add the spinner view controller
        addChild(child)
        child.view.frame = UIScreen.main.bounds
        view.addSubview(child.view)
        child.didMove(toParent: self)
        self.tabBarController?.tabBar.alpha = 0.1
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
    }
    
    func hideSpinner() {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
        self.tabBarController?.tabBar.alpha = 1
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
    }

}
