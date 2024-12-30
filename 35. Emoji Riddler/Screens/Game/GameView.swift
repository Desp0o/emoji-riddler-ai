//
//  Game.swift
//  35. Emoji Riddler
//
//  Created by Despo on 29.12.24.
//

import UIKit
import SwiftUI

final class GameView: UIViewController {
  private let loadingIndicator: LoadingIndicator
  private var hostingController: UIHostingController<SwiftUIListView>?
  let gameCategory: Categories
  let vm: GameViewModel?
  private var isHintShown = false
  
  private lazy var contentView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideHint))
    view.addGestureRecognizer(tapGesture)
    
    return view
  }()
  
  private lazy var navigationStack: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.spacing = 10
    stack.distribution = .fill
    return stack
  }()
  
  private lazy var buttonsStack: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.spacing = 8
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goBack))
    stack.addGestureRecognizer(tapGesture)
    
    return stack
  }()
  
  private lazy var backButton: UIImageView = {
    let image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
    image.image = UIImage(systemName: "arrow.left")
    image.tintColor = .mainGreen
    return image
  }()
  
  private lazy var backTitle: UILabel = {
    let label = UILabel()
    label.configureCustomText(
        text: "Back",
        color: .mainGreen,
        isBold: true,
        size: 16
      )
    return label
  }()
  
  private lazy var livesStack: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.distribution = .equalSpacing
    return stack
  }()
  
  private lazy var scoreLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var hintButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configureWith(
      title: "Hint",
      fontSize: 16,
      titleColor: .secondaryWhite,
      backgroundColor: .mainGreen
    )
    button.layer.cornerRadius = 10
    button.addAction(UIAction(handler: {[weak self] _ in
      self?.showHint()
    }), for: .touchUpInside)
    return button
  }()
  
  private lazy var hintLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.clipsToBounds = true
    label.layer.cornerRadius = 16
    label.backgroundColor = .mainGreen
    label.textColor = .secondaryWhite
    label.textAlignment = .center
    label.isHidden = true
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var attemptsLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var questionView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .white
    view.layer.cornerRadius = 10
    view.layer.borderWidth = 4
    view.layer.borderColor = UIColor.mainGreen.cgColor
    return view
  }()
  
  private lazy var questionTitle: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var nextButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.configureWith(title: "Next", fontSize: 18, titleColor: .mainGreen, backgroundColor: .secondaryWhite)
    button.layer.cornerRadius = 10
    button.layer.borderWidth = 4
    button.layer.borderColor = UIColor.mainGreen.cgColor
    button.addAction(UIAction(handler: {[weak self] _ in
      self?.vm?.fetchNextQuestion()}), for: .touchUpInside)
    return button
  }()
  
  private lazy var spacer: UIView = {
    let view = UIView()
    return view
  }()
  
  init(gameCategory: Categories,
       loadingIndicator: LoadingIndicator = LoadingIndicator()
  ) {
    self.vm = GameViewModel(gameCategory: gameCategory)
    self.gameCategory = gameCategory
    self.loadingIndicator = loadingIndicator
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
  }
  
  private func setupUI() {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    
    vm?.delegate = self
    vm?.attemptsDelegate = self
    vm?.questionDelegate = self
    vm?.indicatorDelegate = self
    vm?.looserDelegate = self
    view.backgroundColor = .secondaryWhite
    view.addSubview(contentView)
    
    contentView.addSubview(navigationStack)
    navigationStack.addArrangedSubview(buttonsStack)
    navigationStack.addArrangedSubview(spacer)
    
    buttonsStack.addArrangedSubview(backButton)
    buttonsStack.addArrangedSubview(backTitle)
    
    contentView.addSubview(questionView)
    questionView.addSubview(questionTitle)
    contentView.addSubview(nextButton)
    contentView.addSubview(livesStack)
    contentView.addSubview(livesStack)
    livesStack.addArrangedSubview(scoreLabel)
    livesStack.addArrangedSubview(hintButton)
    livesStack.addArrangedSubview(attemptsLabel)
    
    loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(loadingIndicator)
    view.bringSubviewToFront(loadingIndicator)
    loadingIndicator.center = view.center
    loadingIndicator.startAnimating()
    
    view.addSubview(hintLabel)
    
    setupConstraints()
    showNextQuestion()
    setupPoints()
    setupAttepmts()
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      navigationStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
      navigationStack.topAnchor.constraint(equalTo: contentView.topAnchor),
      navigationStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 50),
      
      livesStack.topAnchor.constraint(equalTo: navigationStack.bottomAnchor, constant: 50),
      livesStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
      livesStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
      
      questionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
      questionView.topAnchor.constraint(equalTo: livesStack.topAnchor, constant: 50),
      questionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
      questionView.heightAnchor.constraint(equalToConstant: 150),
      
      questionTitle.centerXAnchor.constraint(equalTo: questionView.centerXAnchor),
      questionTitle.centerYAnchor.constraint(equalTo: questionView.centerYAnchor),
      
      nextButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      nextButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50),
      nextButton.widthAnchor.constraint(equalToConstant: 100),
      nextButton.heightAnchor.constraint(equalToConstant: 50),
      
      hintButton.widthAnchor.constraint(equalToConstant: 50),
      
      hintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
      hintLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
      hintLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
      hintLabel.heightAnchor.constraint(equalToConstant: 60),
      
      loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
  
  @MainActor
  private func setupAnswers(nextQuestion: GameModel) {
    guard let viewModel = vm else { return }
    
    hostingController?.willMove(toParent: nil)
    hostingController?.view.removeFromSuperview()
    hostingController?.removeFromParent()
    
    let swiftUIView = SwiftUIListView(item: nextQuestion, vm: viewModel)
    hostingController = UIHostingController(rootView: swiftUIView)
    addChild(hostingController!)
    contentView.addSubview(hostingController!.view)
    
    guard let hostingController = hostingController  else {return}
    hostingController.didMove(toParent: self)
    hostingController.view.backgroundColor = .clear
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
      hostingController.view.topAnchor.constraint(equalTo: questionView.bottomAnchor, constant: 50),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120)
    ])
  }
  
  private func setupPoints() {
    scoreLabel.configureCustomText(
      text: "Points: \(vm?.points ?? 0)",
      color: .mainGreen,
      isBold: true,
      size: 16)
  }
  
  private func setupAttepmts() {
    attemptsLabel.configureCustomText(
      text: "Try: \(vm?.attempts ?? 0)",
      color: .mainGreen,
      isBold: true,
      size: 16
    )
  }
      
  func showHint() {
    hintLabel.isHidden = false
    hintLabel.alpha = 0
    UIView.animate(withDuration: 0.2, animations: {
      self.hintLabel.alpha = 1
    })
  }
  
  @objc func hideHint() {
    UIView.animate(withDuration: 0.2, animations: {
      self.hintLabel.alpha = 0
    }, completion: { _ in
      self.hintLabel.isHidden = true
    })
  }
  
  @objc func goBack() {
    navigationController?.popViewController(animated: true)
  }
}

extension GameView: PointsDelegate {
  func updateScore(to score: Int) {
    DispatchQueue.main.async {[weak self] in
      self?.scoreLabel.text = "Points: \(score)"
    }
  }
}

extension GameView: AttemptsDelegate {
  func updateAttpemts(to tries: Int) {
    DispatchQueue.main.async{[weak self] in
      self?.attemptsLabel.configureCustomText(
        text: "Try: \(tries)",
        color: .mainGreen,
        isBold: true,
        size: 16
      )
    }
  }
}

extension GameView: QuestionDelegate {
  private func showNextQuestion() {
    if let nextQuestion = vm?.loadNextQuestion(cat: gameCategory) {
      DispatchQueue.main.async {
        self.questionTitle.text = nextQuestion.question
        self.setupAnswers(nextQuestion: nextQuestion)
        self.hintLabel.text = nextQuestion.hint
      }
    }
  }
  
  func updateQuestion() {
    showNextQuestion()
  }
}

extension GameView: IndicatorDelegate {
  func updateLoadingIndicator() {
    if vm?.isLoading == true {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
        self?.contentView.isHidden = true
        self?.loadingIndicator.startAnimating()
      }
      
    } else {
      DispatchQueue.main.async {[weak self] in
        self?.contentView.isHidden = false
        self?.loadingIndicator.stopAnimating()
      }
    }
  }
}

extension GameView: LoserDelegate {
  func updateLooserState() {
      let alert = UIAlertController(
          title: "Game Over",
          message: "You've completed all the questions!",
          preferredStyle: .alert
      )
      
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
          self?.navigationController?.popViewController(animated: false)
      }))
      
      present(alert, animated: true)
  }
}
