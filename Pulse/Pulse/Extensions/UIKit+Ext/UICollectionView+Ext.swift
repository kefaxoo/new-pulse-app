//
//  UICollectionView+Ext.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit

extension UICollectionView {
    func register(_ cells: AnyClass...) {
        cells.forEach { [weak self] cell in
            let id = String(describing: cell.self)
            self?.register(cell, forCellWithReuseIdentifier: id)
        }
    }
}
