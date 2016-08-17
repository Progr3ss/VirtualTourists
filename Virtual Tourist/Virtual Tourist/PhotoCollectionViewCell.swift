//
//  PhotoCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 7/21/16.
//  Copyright © 2016 martin chibwe. All rights reserved.

import Foundation
import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var photo: Photo? = nil {
        didSet {
            oldValue?.cancelLoadingImage()
            loading = true
            photo?.startLoadingImage({ (image, error) -> Void in
                self.imageView.image = image
                self.loading = error != nil
            })
        }
    }


    var loading: Bool {
        set {
            if newValue {
                imageView.image = nil
                activityIndicator.startAnimating()
                activityIndicator.hidden = false
            }
            else {
                activityIndicator.stopAnimating()
                activityIndicator.hidden = true
            }
        }
        get {
            return !activityIndicator.hidden
        }
    }
}