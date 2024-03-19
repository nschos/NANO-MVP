//
//  DynamicHeightCollectionView.swift
//  NetworkCallsGA
//
//  Created by Marina De Pazzi on 30/06/23.
//

import UIKit
class DynamicHeightCollectionView: UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            self.invalidateIntrinsicContentSize()
        }
    }
    override var intrinsicContentSize: CGSize {
        return collectionViewLayout.collectionViewContentSize
    }
}
