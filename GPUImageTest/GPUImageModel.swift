//
//  GPUImageModel.swift
//  GPUImageTest
//
//  Created by Sergii Kotyk on 3/3/2022.
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


import Foundation
import UIKit
import GPUImage
import AVKit

class GPUImageModel{
    
    //MARK: - Image
    func RGBfilter(image: UIImage) -> UIImage{ // Color Adjustments
        let f = GPUImageRGBFilter()
        f.blue = 25
        return f.image(byFilteringImage: image)
        
    }
    
    func polkaDotFilter(image: UIImage) -> UIImage{ // Visual Effects
        let f = GPUImagePolkaDotFilter()
        f.dotScaling = 0.9
        return f.image(byFilteringImage: image)
    }
    
    func CAFilters(image: UIImage) -> UIImage{ // any 3 from Color Adjustments
        let picture = GPUImagePicture(image: image)
        let f1 = GPUImageGammaFilter()
        f1.gamma = 2
        let f2 = GPUImageSaturationFilter()
        f2.saturation = 2
        let f3 = GPUImageContrastFilter()
        f3.contrast = 3
        picture?.addTarget(f1)
        f1.addTarget(f2)
        f2.addTarget(f3)
        f3.useNextFrameForImageCapture()
        picture?.processImage()
        
        return f3.imageFromCurrentFramebuffer()
    }
    
    func VEFilters(image: UIImage) -> UIImage{ // any 3 from Visual Effects
        let picture = GPUImagePicture(image: image)
        let f1 = GPUImagePixellateFilter()
        f1.fractionalWidthOfAPixel = 0.01
        let f2 = GPUImageHalftoneFilter()
        f2.fractionalWidthOfAPixel = 0.01
        picture?.addTarget(f1)
        f1.addTarget(f2)
        f2.useNextFrameForImageCapture()
        picture?.processImage()
        
        return f2.imageFromCurrentFramebuffer()
    }
    
    func filterLUT(image: UIImage) -> UIImage{
        let picture = GPUImagePicture(image: image)
        let lut = GPUImagePicture(image: UIImage(named: "lut1"))!
        let f = GPUImageLookupFilter()
        
        lut.addTarget(f, atTextureLocation: 1)
        picture?.addTarget(f, atTextureLocation: 0)
        f.useNextFrameForImageCapture()
        lut.processImage()
        picture?.processImage()
        return f.imageFromCurrentFramebuffer()
    }
    
    func imageFiltersArray(image: UIImage) -> [UIImage]{
        var array: [UIImage] = []
        for i in 1...5{
            switch i{
            case 1:
                array.append(RGBfilter(image: image))
            case 2:
                array.append(polkaDotFilter(image: image))
            case 3:
                array.append(CAFilters(image: image))
            case 4:
                array.append(VEFilters(image: image))
            default:
                array.append(filterLUT(image: image))
            }
        }
        
        return array
    }
    
    //MARK: - video
    
    func RGBfilterVideo(playerItem: AVPlayerItem, view: UIView, player: inout AVPlayer){
        player = AVPlayer(playerItem: playerItem)
        guard let gpuMovie = GPUImageMovie(playerItem: playerItem) else {fatalError()}
        gpuMovie.playAtActualSpeed = true

        let filteredView = GPUImageView()
        filteredView.frame = view.frame
        filteredView.center.y = view.center.y - 90
        view.addSubview(filteredView)

        let f = GPUImageRGBFilter()
        f.blue = 25
        
        gpuMovie.addTarget(f)
        gpuMovie.playAtActualSpeed = true
        f.addTarget(filteredView)

        gpuMovie.startProcessing()
        player.play()
        

    }
    
    func polkaDotFilterVideo(playerItem: AVPlayerItem, view: UIView, player: inout AVPlayer){
        player = AVPlayer(playerItem: playerItem)
        guard let gpuMovie = GPUImageMovie(playerItem: playerItem) else {fatalError()}
        gpuMovie.playAtActualSpeed = true

        let filteredView: GPUImageView = GPUImageView();
        filteredView.frame = view.frame
        filteredView.center.y = view.center.y - 90
        view.addSubview(filteredView)

        let f = GPUImagePolkaDotFilter()
        f.dotScaling = 0.9
        
        gpuMovie.addTarget(f)
        gpuMovie.playAtActualSpeed = true
        f.addTarget(filteredView)

        gpuMovie.startProcessing()
        player.play()
    }
    
    func CAFiltersVideo(playerItem: AVPlayerItem, view: UIView, player: inout AVPlayer){
        player = AVPlayer(playerItem: playerItem)
        guard let gpuMovie = GPUImageMovie(playerItem: playerItem) else {fatalError()}
        gpuMovie.playAtActualSpeed = true

        let filteredView: GPUImageView = GPUImageView();
        filteredView.frame = view.frame
        filteredView.center.y = view.center.y - 90
        view.addSubview(filteredView)

        let f1 = GPUImagePixellateFilter()
        f1.fractionalWidthOfAPixel = 0.01
        let f2 = GPUImageHalftoneFilter()
        f2.fractionalWidthOfAPixel = 0.01
        gpuMovie.addTarget(f1)
        f1.addTarget(f2)
        
        gpuMovie.playAtActualSpeed = true
        f2.addTarget(filteredView)

        gpuMovie.startProcessing()
        player.play()
    }
    
    func VEFiltersVideo(playerItem: AVPlayerItem, view: UIView, player: inout AVPlayer){
        player = AVPlayer(playerItem: playerItem)
        guard var gpuMovie = GPUImageMovie(playerItem: playerItem) else {fatalError()}
        gpuMovie.playAtActualSpeed = true

        let filteredView: GPUImageView = GPUImageView();
        filteredView.frame = view.frame
        filteredView.center.y = view.center.y - 90
        view.addSubview(filteredView)

        let f1 = GPUImageGammaFilter()
        f1.gamma = 2
        let f2 = GPUImageSaturationFilter()
        f2.saturation = 2
        let f3 = GPUImageContrastFilter()
        f3.contrast = 3
        
        gpuMovie.addTarget(f1)
        f1.addTarget(f2)
        f2.addTarget(f3)
        gpuMovie.playAtActualSpeed = true
        f3.addTarget(filteredView)

        gpuMovie.startProcessing()
        player.play()
    }
    
    let f: GPUImageLookupFilter = {
        let filter = GPUImageLookupFilter()
        filter.intensity = 1.0
        return filter
    }()
    
    let lut: GPUImagePicture? = {
        if let imagePicture = GPUImagePicture(image: UIImage(named:"lut1")) {
            return imagePicture
        } else {
            print("GPUImagePicture Nil")
            return nil
        }
    }()
    
    let filteredView: GPUImageView = {
        let imageView = GPUImageView()
        imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        imageView.isUserInteractionEnabled = true

        return imageView
    }()
    
    func LUTFilterVideo(playerItem: AVPlayerItem, view: UIView, player: inout AVPlayer){
        player = AVPlayer(playerItem: playerItem)
        let gpuMovie: GPUImageMovie? = {
            if let movie = GPUImageMovie(playerItem: playerItem){
                return movie
            } else {
                return nil
            }
        }()
        filteredView.frame = view.frame
        filteredView.center.y = view.center.y - 90
        
        gpuMovie!.playAtActualSpeed = true
        view.addSubview(filteredView)

        gpuMovie!.addTarget(f)
        lut!.addTarget(f)
        lut!.processImage()
        f.addTarget(filteredView)
        
        gpuMovie!.startProcessing()
        player.play()
    }
   
}

