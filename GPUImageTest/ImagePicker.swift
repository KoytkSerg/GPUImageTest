//
//  ImagePicker.swift
//  GPUImageTest
//
//  Created by Sergii Kotyk on 23/2/2022.
//

import Foundation
import UIKit
import MobileCoreServices

class ImagePicker{
    static func startMediaBrowser(
      delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate,
      sourceType: UIImagePickerController.SourceType
    ) {
      guard UIImagePickerController.isSourceTypeAvailable(sourceType)
        else { return }

      let mediaUI = UIImagePickerController()
      mediaUI.sourceType = sourceType
      mediaUI.mediaTypes = ["public.movie", "public.image" ]
      mediaUI.allowsEditing = true
      mediaUI.delegate = delegate
      delegate.present(mediaUI, animated: true, completion: nil)
    }
}

