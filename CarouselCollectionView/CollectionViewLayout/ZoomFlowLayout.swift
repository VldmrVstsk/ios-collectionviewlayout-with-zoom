//
//  ZoomFlowLayout.swift
//  CarouselCollectionView
//
//  Created by vvisotskiy on 11.05.2020.
//  Copyright © 2020 VldmrVstsk. All rights reserved.
//

import UIKit

final class ZoomFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        guard let collectionView = collectionView else { return }
        scrollDirection = .horizontal
        minimumLineSpacing = 10
        minimumInteritemSpacing = 10
        
        collectionView.decelerationRate = .fast
        
        let inset = collectionView.bounds.size.width / 2 - itemSize.width / 2 - 5
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect) ?? []
        
        let newLayoutAttributes = layoutAttributes.compactMap { layoutAttributesForItem(at: $0.indexPath) }
        
        return newLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttribute = super.layoutAttributesForItem(at: indexPath)
        
        guard let collectionView = collectionView,
            let newLayoutAttribute = layoutAttribute?.copy() as? UICollectionViewLayoutAttributes else { return layoutAttribute }
        
        let currentContentOffset = collectionView.contentOffset

        let visibleRect = CGRect(x: currentContentOffset.x,
                                 y: currentContentOffset.y,
                                 width: collectionView.bounds.width,
                                 height: collectionView.bounds.height)

        let centerXOfVisibleRect = visibleRect.midX
        
        let distanceFromCenter = centerXOfVisibleRect - newLayoutAttribute.center.x
        let absDistanceFromCenter = min(abs(distanceFromCenter), Constants.startScallingOffset)

        let scaleCoef = absDistanceFromCenter * (Constants.minimumScaleCoef - 1) / Constants.startScallingOffset
    
        newLayoutAttribute.alpha = 1 - abs(scaleCoef)
        
        let scaleFactor = 1 - abs(scaleCoef) / 2
        newLayoutAttribute.transform3D = CATransform3DScale(CATransform3DIdentity, scaleFactor, scaleFactor, 1)

        return newLayoutAttribute
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        let collectionViewSize = collectionView.bounds.size
        let proposedRect = CGRect(x: proposedContentOffset.x,
                                  y: 0,
                                  width: collectionViewSize.width,
                                  height: collectionViewSize.height)
        
        guard let layoutAttributes = layoutAttributesForElements(in: proposedRect)?
            .filter({ $0.representedElementCategory == .cell }) else { return proposedContentOffset }

        var candidateAttributes: UICollectionViewLayoutAttributes?
        let proposedContentOffsetCenterX = proposedContentOffset.x + collectionViewSize.width / 2

        for attributes in layoutAttributes {
            if candidateAttributes == nil {
                candidateAttributes = attributes
                continue
            }
            
            if abs(attributes.center.x - proposedContentOffsetCenterX) < abs(candidateAttributes!.center.x - proposedContentOffsetCenterX) {
                candidateAttributes = attributes
            }
        }
        
        if candidateAttributes == nil {
            return proposedContentOffset
        }
        
        var newOffsetX = candidateAttributes!.center.x - (collectionView.bounds.size.width / 2)
        
        let offset = newOffsetX - collectionView.contentOffset.x
        
        if (velocity.x < 0 && offset > 0) || (velocity.x > 0 && offset < 0) {
            let pageWidth = itemSize.width + minimumLineSpacing
            newOffsetX += velocity.x > 0 ? pageWidth : -pageWidth
        }
        
        return CGPoint(x: newOffsetX, y: proposedContentOffset.y)
    }
}

extension ZoomFlowLayout {
    private enum Constants {
        static let startScallingOffset: CGFloat = 50
        static let minimumScaleCoef: CGFloat = 0.3
    }
}
