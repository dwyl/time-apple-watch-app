//
//  setupNavImage.swift
//  time
//
//  Created by Sohil Pandya on 06/04/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import UIKit

func setupNavImage() -> UIView {
    let image : UIImage = UIImage(named: "dwyl-heart-logo")!
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    imageView.contentMode = .scaleAspectFit
    imageView.image = image
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    return view
}
