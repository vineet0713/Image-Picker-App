//
//  ViewController.swift
//  Image Picker Experiment
//
//  Created by Vineet Joshi on 1/11/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import UIKit

let DEFAULT_TEXT = ["TOP", "BOTTOM"]
let MEME_TEXT_ATTRIBUTES: [String : Any] = [
    NSAttributedStringKey.strokeColor.rawValue : UIColor.black,
    NSAttributedStringKey.foregroundColor.rawValue : UIColor.white,
    NSAttributedStringKey.font.rawValue : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
    NSAttributedStringKey.strokeWidth.rawValue : 4.0
]

struct Meme {
    let topText: String?
    let bottomText: String?
    let originalImage: UIImage?
    let memedImage: UIImage?
}

// To be a delegate of the UIImagePickerController, this also needs to conform to the UINavigationControllerDelegate protocol
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: Initialize outlets and class variables
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topMemeField: UITextField!
    @IBOutlet weak var bottomMemeField: UITextField!
    
    // top Toolbar and its outlets:
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // bottom Toolbar and its outlets:
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var chooseImageButton: UIBarButtonItem!
    
    // default value of the final Meme:
    var finalMeme = Meme(topText: nil, bottomText: nil, originalImage: nil, memedImage: nil)
    
    var bottomEditing = false
    
    // MARK: Overriden functions from UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //print(UIFont.fontNames(forFamilyName: "Helvetica Neue"))
        
        // if the current device does not have a camera, then disable the Camera button:
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // a 'guard' statement is like 'if not let'!
        
        topMemeField.tag = 0
        topMemeField.text = DEFAULT_TEXT[topMemeField.tag]
        topMemeField.defaultTextAttributes = MEME_TEXT_ATTRIBUTES
        topMemeField.textAlignment = NSTextAlignment.center
        topMemeField.delegate = self
        
        bottomMemeField.tag = 1
        bottomMemeField.text = DEFAULT_TEXT[bottomMemeField.tag]
        bottomMemeField.defaultTextAttributes = MEME_TEXT_ATTRIBUTES
        bottomMemeField.textAlignment = NSTextAlignment.center
        bottomMemeField.delegate = self
        
        // disables the "Share" Button:
        shareButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // NSNotifications provide a way to announce information throughout an app, even across classes
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unsubscribeFromKeyboardNotifications()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Keyboard Notification functions
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        // '.UIKeyboardWillShow' is shortened version of 'Notification.Name.UIKeyboardWillShow'
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomEditing {
            // moves the View up by the height of the keyboard: (so the keyboard won't cover up the content!)
            self.view.frame.origin.y -= self.getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if bottomEditing {
            // moves the View up by the height of the keyboard: (so the keyboard won't cover up the content!)
            self.view.frame.origin.y += self.getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        // Notifications carry information in the 'userInfo' Dictionary
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue  // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        // '.UIKeyboardWillShow' is shortened version of 'Notification.Name.UIKeyboardWillShow'
    }
    
    // MARK: Picking an Image
    
    @IBAction func pickImage(_ sender: Any) {
        // launches a UIImagePickerController
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        if (sender as! UIBarButtonItem).tag == 0 {
            pickerController.sourceType = .camera
        } else {
            pickerController.sourceType = .photoLibrary
        }
        self.present(pickerController, animated: true, completion: nil)
    }
    
    // part of the UIImagePickerController Delegate:
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = userImage
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // part of the UIImagePickerController Delegate:
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // sets the bottomEditing variable to true if the user begins editing the bottom TextField
        bottomEditing = (textField.tag == 1)
        if (textField.tag == 0 && textField.text == "TOP") || (textField.tag == 1 && textField.text == "BOTTOM") {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        finishEditing(with: textField)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        finishEditing(with: textField)
    }
    
    func finishEditing(with textField: UITextField) {
        // if the user left the TextField empty, then add the default text to it
        if textField.text == "" {
            textField.text = DEFAULT_TEXT[textField.tag]
        } else {
            textField.text = textField.text?.trimmingCharacters(in: .whitespaces)
        }
        // if user has selected an image and both meme fields are filled, then enable the "Share" Button
        shareButton.isEnabled = (imagePickerView.image != nil && topMemeField.text != DEFAULT_TEXT[0] && bottomMemeField.text != DEFAULT_TEXT[1])
    }
    
    // MARK: Saving an Image
    
    @IBAction func saveImage(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        activityController.completionWithItemsHandler = { activity, success, items, error in
            self.saveMeme()
            self.confirmMemeSaved()
        }
        self.present(activityController, animated: true, completion: nil)
    }
    
    func saveMeme() {
        // create the meme
        finalMeme = Meme(topText: topMemeField.text!, bottomText: bottomMemeField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
    }
    
    // Given by instructor:
    func generateMemedImage() -> UIImage {
        // hides the top/bottom Toolbars:
        hideToolbars(hide: true)
        
        // render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // shows the top/bottom Toolbars:
        hideToolbars(hide: false)
        
        return memedImage
    }
    
    func hideToolbars(hide: Bool) {
        topToolbar.isHidden = hide
        bottomToolbar.isHidden = hide
    }
    
    func confirmMemeSaved() {
        let alertController = UIAlertController(title: "Success", message: "Your meme was successfully saved!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"Success\" alert occured.")
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}

