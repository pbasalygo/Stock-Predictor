//
//  LoginViewController.swift
//  Stock Predictor
//
//  Created by Paweł Basałygo on 13/05/2022.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var PasswordTextBox: UITextField!
    @IBOutlet weak var EmailTextBox: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func LoginButtonPressed(_ sender: UIButton) {
        if  let email = EmailTextBox.text, let password = PasswordTextBox.text{
            
            
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let e = error{
                    let errorMessage = e.localizedDescription
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    self?.present(alert, animated: true)
                    
              // ...
            }
                else{
                    self?.performSegue(withIdentifier: "LoginToHome", sender: self)
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
        
}
