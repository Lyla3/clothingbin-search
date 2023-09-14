//
//  Extension + View.swift
//  daummap
//
//  Created by Lyla on 2023/09/12.
//

import Foundation

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}
