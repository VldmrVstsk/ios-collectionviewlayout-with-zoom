//
//  ViewController.swift
//  CarouselCollectionView
//
//  Created by vvisotskiy on 08.05.2020.
//  Copyright © 2020 VldmrVstsk. All rights reserved.
//

import UIKit

final class ImageCell: UICollectionViewCell {
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    public func setImage(_ image: UIImage) {
        imageView.image = image
    }
    
    private func initialSetup() {
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

class ViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var zoomLayout: ZoomFlowLayout!
    
    private let images = [UIImage(named: "afghanistan"),
                          UIImage(named: "algeria"),
                          UIImage(named: "andora"),
                          UIImage(named: "angola"),
                          UIImage(named: "argentina"),
                          UIImage(named: "armenia"),
                          UIImage(named: "australia"),
                          UIImage(named: "austria")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zoomLayout.itemSize = CGSize(width: 100, height: 100)
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCell
        if let image = images[indexPath.row] {
            cell.setImage(image)
        }
        return cell
    }
}
