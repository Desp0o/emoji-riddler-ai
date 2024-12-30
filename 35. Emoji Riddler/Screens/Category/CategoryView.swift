//
//  Main.swift
//  35. Emoji Riddler
//
//  Created by Despo on 29.12.24.
//

import Foundation
import UIKit

final class CategoryView: UIViewController {
  private var vm: CategoryViewModel
  
  private lazy var category: UIStackView = {
    let view = UIStackView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .vertical
    view.spacing = 10
    
    return view
  }()
  
  private lazy var categoryTab: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.layer.borderWidth = 1
    label.layer.cornerRadius = 10
    return label
  }()
  
  init(vm: CategoryViewModel = CategoryViewModel()) {
    self.vm = vm
    super.init(nibName: nil, bundle: nil)
  }
  
  @MainActor required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
  }
  
  private func setupUI() {
    view.backgroundColor = .mainGreen
    
    view.addSubview(category)
    setupConstraints()
    setupTabs()
  }
  
  
  func setupConstraints() {
    NSLayoutConstraint.activate([
      category.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      category.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      category.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
      category.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50)

    ])
  }
  
  func setupTabs() {
    for i in vm.categoryArray {
      let tab = UIButton()
      tab.translatesAutoresizingMaskIntoConstraints = false
      tab.configureWith(title: "\(i)".capitalized, titleColor: .mainGreen)
      tab.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
      tab.backgroundColor = .secondaryWhite
      tab.layer.cornerRadius = 10
      
      tab.addAction(UIAction(handler: {[weak self] _ in
        self?.navigationController?.pushViewController(GameView(gameCategory: i), animated: true)
      }), for: .touchUpInside)
      
      category.addArrangedSubview(tab)
    
      NSLayoutConstraint.activate([
        tab.heightAnchor.constraint(equalToConstant: 50)
      ])
    }
  }
}
