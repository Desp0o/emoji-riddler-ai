//
//  LoadingIndicator.swift
//  35. Emoji Riddler
//
//  Created by Despo on 29.12.24.
//

import UIKit

final class LoadingIndicator: UIView {
  private let activityIndicator = UIActivityIndicatorView(style: .large)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
  }
  
  private func setupUI() {
    activityIndicator.color = .mainGreen
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    
    addSubview(activityIndicator)
    
    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 10.0),
      activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }
  
  func startAnimating() {
    activityIndicator.startAnimating()
    self.isHidden = false
  }
  
  func stopAnimating() {
    activityIndicator.stopAnimating()
    self.isHidden = true
  }
}
