//
//  ViewController.swift
//  GPUImageTest
//
//  Created by Sergii Kotyk on 18/2/2022.
//

/*
 Создайте приложение, в котором есть один экран, состоящий из: переключателя фото/видео, медиазоны, выбора
 из пяти фильтров (можно выбрать один, по умолчанию выбран первый). Добавьте в приложение любое фото и
 видео. Если в переключателе выбрано «Фото», то в медиазоне должно показываться фото с выбранным фильтром,
 если выбрано «Видео» — должно проигрываться видео с выбранным фильтром. При нажатии на фильтр, он должен
 сразу применяться. Реализуйте следующие пять фильтров:
 любой из группы Color Adjustments;
 комбинацию из любых трех фильтров;
 любой из группы Visual Effects;
 комбинацию любых двух из группы Visual Effects;
 свой собственный фильтр на основе lookup table (LUT). Можете найти и добавить готовый или создать собственный LUT в фотошопе
 */

import UIKit
import Photos
import AVKit
import ObjectiveC
import GPUImage

class FilterController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBAction func saveImageButton(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    let filter = GPUImageModel()
    
    var isVideo = false
    var imagePicker: ImagePicker!
    var imageArray:[UIImage] = []
    
    var asset: AVAsset?
    var playerItem: AVPlayerItem! = nil
    var player : AVPlayer? = nil
    

    

    
    func videoFilters(filterNumber: Int){
        switch filterNumber {
        case 0:
            filter.RGBfilterVideo(playerItem: playerItem, view: imageView, player: &player!)
        case 1:
            filter.polkaDotFilterVideo(playerItem: playerItem, view: imageView, player: &player!)
        case 2:
            filter.VEFiltersVideo(playerItem: playerItem, view: imageView, player: &player!)
        case 3:
            filter.CAFiltersVideo(playerItem: playerItem, view: imageView, player: &player!)
        case 4:
            filter.LUTFilterVideo(playerItem: playerItem, view: imageView, player: &player!)
        default:
            print("no filter")
            fatalError()
        }
    }
    

    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your filterd image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterCollectionView.dataSource = self
        filterCollectionView.delegate = self
    
        if isVideo{
            saveButton.isHidden = true
            playerItem = AVPlayerItem(asset: asset!)
            player = AVPlayer()
            filter.RGBfilterVideo(playerItem: playerItem, view: imageView, player: &player!)
        } else {
            imageView.image = imageArray[0]
        }

    }


}
extension FilterController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! FilterViewCell
        cell.filterImage.image = imageArray[indexPath.row]
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = UIScreen.main.bounds.width / 2
        let h = UIScreen.main.bounds.height / 6
        return CGSize(width: w, height: h)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isVideo{
            player = nil
            playerItem = nil
            playerItem = AVPlayerItem(asset: asset!)
            player = AVPlayer()
            videoFilters(filterNumber: indexPath.row)
        } else {
            imageView.image = imageArray[indexPath.row]
            
        }
    }
    
    
    
}


