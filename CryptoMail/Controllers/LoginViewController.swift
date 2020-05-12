//
//  LoginViewController.swift
//  CryptoMail
//
//  Created by Ali Şengür on 7.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class LoginViewController: UIViewController {

    
    //MARK: -Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
        handleTextField()
        loginButton.isEnabled = false
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if Auth.auth().currentUser != nil {
            let vc = self.storyboard?.instantiateViewController(identifier: "TabBarController") as! UITabBarController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }

    
    func handleTextField() {
        emailTextField.addTarget(self, action: #selector(LoginViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(LoginViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    
    @objc func textFieldDidChange() {
           
           guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
               loginButton.isEnabled = false
               loginButton.setTitleColor(UIColor.lightText, for: UIControl.State.normal)
               return
           }
           loginButton.isEnabled = true
           loginButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
       }

    

    //MARK: -Login Action
    @IBAction func loginButtonDidTapped(_ sender: Any) {
        
        view.endEditing(true)
        AuthService.signIn(email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
            
            self.errorLabel.text = ""
            let vc = self.storyboard?.instantiateViewController(identifier: "TabBarController") as! UITabBarController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
        }, onError: { error in
              switch error {
              case .userNotFound:
                self.errorLabel.text = "User not found"
              case .wrongPassword:
                self.errorLabel.text = "Enter the password correctly"
              case .invalidEmail:
                self.errorLabel.text = "Enter the email address correctly"
              default:
                print("Error")
              }
        })

        
    }
    
    
    @IBAction func signUpDidTapped(_ sender: Any) {
        let signUpVC = self.storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        present(signUpVC, animated: true, completion: nil)
        
    }
}
