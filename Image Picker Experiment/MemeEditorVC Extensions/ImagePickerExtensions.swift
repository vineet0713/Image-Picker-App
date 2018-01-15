//
//  MemeEditorViewControllerExtension.swift
//  Image Picker Experiment
//
//  Created by Vineet Joshi on 1/15/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import Foundation
import UIKit

// To be a delegate of the UIImagePickerController, this also needs to conform to the UINavigationControllerDelegate protocol
extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
}
