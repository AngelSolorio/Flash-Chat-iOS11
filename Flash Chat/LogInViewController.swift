//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController, UITextFieldDelegate {
    private var shouldStartValidations = false

    // MARK: - IBOutlets
    
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    // MARK: - View Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the delegate of TextFields to customize their behaivor
        emailTextfield.delegate = self
        passwordTextfield.delegate = self

        // Executes textFieldDidChange method to validate text entered
        emailTextfield.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        passwordTextfield.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)

        // Customize textFields borders
        emailTextfield.layer.cornerRadius = 8.0
        emailTextfield.layer.borderWidth = CGFloat(1.0)
        emailTextfield.layer.borderColor = UIColor.white.cgColor
        passwordTextfield.layer.cornerRadius = 8.0
        passwordTextfield.layer.borderWidth = CGFloat(1.0)
        passwordTextfield.layer.borderColor = UIColor.white.cgColor

        emailTextfield.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - IBAction Methods
   
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
                SVProgressHUD.showSuccess(withStatus: "Logged In!")
                SVProgressHUD.setForegroundColor(UIColor.flatGreen)
                SVProgressHUD.dismiss(withDelay: 1.0, completion: {
                    self.performSegue(withIdentifier: "goToChat", sender: self)
                })
            }
        }
    }


    // MARK: - UITextFieldDelegate Methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            if textField.isEqual(emailTextfield) && (text.count > 5) {
                passwordTextfield.becomeFirstResponder()
                return true
            } else if textField.isEqual(passwordTextfield) && (text.count > 5) {
                logInPressed(self)
                return true
            }
        }
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Max length: 10 characters for password && 50 characters for email
        if !string.isEmpty &&
            ((textField.isEqual(passwordTextfield) && textField.text?.count ?? 0 == 10) ||
            (textField.isEqual(emailTextfield) && textField.text?.count ?? 0 == 50)) {
            return false
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        shouldStartValidations = true
        validateForm(fieldUpdated: textField)
    }


    // MARK: - Private Methods

    @objc func textFieldDidChange(textField: UITextField) {
        if shouldStartValidations {
            validateForm(fieldUpdated: textField)
        }
    }

    // Validates if the email and password text fields are filled correctly
    private func validateForm(fieldUpdated: UITextField) {
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            if fieldUpdated.isEqual(passwordTextfield) {
                if password.count >= 6 {
                    setTextfieldValid(field: fieldUpdated)
                } else {
                    setTextfieldInvalid(field: fieldUpdated)
                }
            } else if fieldUpdated.isEqual(emailTextfield) {
                if isValidEmail(email) {
                    setTextfieldValid(field: fieldUpdated)
                } else {
                    setTextfieldInvalid(field: fieldUpdated)
                }
            }

            loginButton.isEnabled = (password.count >= 6 && isValidEmail(email))
        }
    }

    // Returns TRUE if the given string is a valid email adress, otherwise FALSE
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "\\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let range = NSRange(location: 0, length: email.utf16.count)
        return regex.firstMatch(in: email, options: [], range: range) != nil
    }

    // Change the border color to red
    private func setTextfieldInvalid(field: UITextField) {
        field.layer.borderColor = UIColor.red.cgColor
    }

    // Change the border color to white
    private func setTextfieldValid(field: UITextField) {
        field.layer.borderColor = UIColor.white.cgColor
    }

    // Displays an Alert Controller
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}  
