//
//  TextFieldExtensions.swift
//  Image Picker Experiment
//
//  Created by Vineet Joshi on 1/15/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import Foundation
import UIKit

extension MemeEditorViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // sets the bottomEditing variable to true if the user begins editing the bottom TextField
        bottomEditing = (textField.tag == 1)
        if (textField.tag == TOP_TAG && textField.text == DEFAULT_TEXT[TOP_TAG]) || (textField.tag == BOTTOM_TAG && textField.text == DEFAULT_TEXT[BOTTOM_TAG]) {
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
        shareButton.isEnabled = (imagePickerView.image != nil && topMemeField.text != DEFAULT_TEXT[TOP_TAG] && bottomMemeField.text != DEFAULT_TEXT[BOTTOM_TAG])
    }
}
