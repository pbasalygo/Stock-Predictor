//
//  RegisterViewController.swift
//  Stock Predictor
//
//  Created by Paweł Basałygo on 13/05/2022.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class RegisterViewController: UIViewController {

    @IBOutlet weak var SubmitButton: UIButton!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func SubmitButtonPressed(_ sender: UIButton) {
        
        if let email = EmailTextField.text , let password = PasswordTextField.text{
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let e = error{
                let errorMessage = e.localizedDescription
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true)
            }
            else{
                self.performSegue(withIdentifier: "RegisterToHome", sender: self)
            }
          // ...
        }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
