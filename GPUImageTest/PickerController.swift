//
//  PickerController.swift
//  GPUImageTest
//
//  Created by Sergii Kotyk on 23/2/2022.
//

import UIKit
import AVFoundation
import GPUImage

class PickerController: UIViewController {

    @IBAction func chooseButton(_ sender: UIButton) {
        ImagePicker.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    }
    
    var playerItem: AVPlayerItem! = nil
    var isVideo = false
    var message = ""
    var imageArray: [UIImage] = []
    var asset: AVAsset?
    let filter = GPUImageModel()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destenation = segue.destination as? FilterController{
            destenation.playerItem = playerItem
            destenation.isVideo = isVideo
            destenation.imageArray = imageArray
            if asset != nil{
                destenation.asset = asset
            }
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension PickerController: UIImagePickerControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    dismiss(animated: true, completion: nil)
    guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String
      else { return }
      if mediaType == "public.movie"{
          let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
          playerItem = AVPlayerItem(url: url!)
          asset = AVAsset(url: url!)
          self.imageArray = filter.imageFiltersArray(image: UIImage(named: "example")!)
          message = "Video loaded"
          isVideo = true
          performSegue(withIdentifier: "showFilters", sender: self)
      }
      if mediaType == "public.image"{
          guard let image = info[.editedImage] as? UIImage
          else { return }
          self.imageArray = filter.imageFiltersArray(image: image)
          message = "Image loaded"
          isVideo = false
          performSegue(withIdentifier: "showFilters", sender: self)
      }
        
    let alert = UIAlertController(
        title: "Loaded",
        message: message,
        preferredStyle: .alert)
    alert.addAction(UIAlertAction(
        title: "OK",
        style: UIAlertAction.Style.cancel,
        handler: nil))
    present(alert, animated: true, completion: nil)
      
  }
}

extension PickerController: UINavigationControllerDelegate{
    
}
