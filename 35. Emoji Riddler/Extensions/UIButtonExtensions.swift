//
//  UIButtonExtensions.swift
//  35. Emoji Riddler
//
//  Created by Despo on 29.12.24.
//

import UIKit

extension UIButton {
    func configureWith(title: String? = nil, fontSize: Int? = nil, titleColor: UIColor? = nil, image: UIImage? = nil, tintColor: UIColor? = .white, backgroundColor: UIColor? = nil) {
        
        self.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(fontSize ?? 20))
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.tintColor = .white
        self.setImage(image, for: .normal)
        self.backgroundColor = backgroundColor
        self.titleLabel?.textAlignment = .center
    }
}
