//
//  SignUpViewController.swift
//  CryptoMail
//
//  Created by Ali Şengür on 7.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class SignUpViewController: UIViewController {

    
    //MARK: -Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.layer.cornerRadius = 5
        signUpButton.isEnabled = false
        handleTextField()
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    func handleTextField() {
        usernameTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
        emailTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    
    
    @objc func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty, let username = usernameTextField.text, !username.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            signUpButton.isEnabled = false
            signUpButton.setTitleColor(UIColor.lightText, for: UIControl.State.normal)
            return
        }
        signUpButton.isEnabled = true
        signUpButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
    }


    @IBAction func signUpButtonDidTapped(_ sender: Any) {

        view.endEditing(true)
        AuthService.signUp(email: emailTextField.text!, username: usernameTextField.text!, password: passwordTextField.text!, onSuccess: {
            
            self.errorLabel.text = ""
            let vc = self.storyboard?.instantiateViewController(identifier: "TabBarController") as! UITabBarController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
        }, onError: { error in
              switch error {
              case .weakPassword:
                self.errorLabel.text = "Lütfen daha güçlü bir şifre girin"
              case .invalidEmail:
                self.errorLabel.text = "Email adresi geçersiz"
              case .emailAlreadyInUse:
                self.errorLabel.text = "Bu email adresi zaten kullanılıyor"
              case .wrongPassword:
                self.errorLabel.text = "Şifreyi hatalı girdiniz"
              default:
                print("Hata")
              }
        })
    }
    
    //self.usernameLabel.text = (snapshot.value as! NSDictionary)["username"] as? String
    

    
}
