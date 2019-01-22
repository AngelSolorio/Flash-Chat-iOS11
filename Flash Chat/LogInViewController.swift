//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {
    // Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    @IBAction func logInPressed(_ sender: AnyObject) {
        // Display a spinner
        SVProgressHUD.show(withStatus: "Connecting...")
        SVProgressHUD.setForegroundColor(UIColor.flatSkyBlueDark)

        // Log in the user
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) {
            (response, error) in
            SVProgressHUD.dismiss()

            if error != nil {
                let alert = UIAlertController(title: "Log In Failed!", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                if let email = response?.user.email {
                    print("Signed In Successfully as " + String(email))
                }
                SVProgressHUD.showSuccess(withStatus: "Signed In!")
                SVProgressHUD.setForegroundColor(UIColor.flatGreen)
                SVProgressHUD.dismiss(withDelay: 1.0, completion: {
                    self.performSegue(withIdentifier: "goToChat", sender: self)
                })
            }
        }
    }
}  
