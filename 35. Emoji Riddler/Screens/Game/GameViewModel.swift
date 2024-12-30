//
//  GameViewController.swift
//  35. Emoji Riddler
//
//  Created by Despo on 29.12.24.
//

import Foundation
import NetworkManagerFramework

protocol IndicatorDelegate: AnyObject {
  func updateLoadingIndicator()
}

protocol QuestionDelegate: AnyObject {
  func updateQuestion()
}

protocol PointsDelegate: AnyObject {
  func updateScore(to score: Int)
}

protocol AttemptsDelegate: AnyObject {
  func updateAttpemts(to tries: Int)
}

protocol LoserDelegate: AnyObject {
  func updateLooserState()
}

@MainActor
final class GameViewModel: ObservableObject {
  var points = 0
  var attempts = 5
  var isLoading = false
  weak var delegate: PointsDelegate?
  weak var attemptsDelegate: AttemptsDelegate?
  weak var questionDelegate: QuestionDelegate?
  weak var indicatorDelegate: IndicatorDelegate?
  weak var looserDelegate: LoserDelegate?
  private var currentQuestionIndex = 0
  private var webService: PostServiceProtocol
  private let api = "https://api.together.xyz/v1/chat/completions"
  private var key = "affa35a77f92307cf711d58b82dad4152dbeadd3ff5bd262021eab70293e5d0d"
  private var gameCategory: Categories
  private var currentCat = ""
  private var currentArray: [String] = []
  @Published private var questionArray: [GameModel] = []
  
  init(webService: PostServiceProtocol = PostService(), gameCategory: Categories) {
    self.webService = webService
    self.gameCategory = gameCategory
    fetchData()
    points = UserDefaults.standard.integer(forKey: "userPoints")
  }
  
  func fetchData() {
    isLoading = true
    indicatorDelegate?.updateLoadingIndicator()
    
    let currentPromptCat = getGameCategory(category: gameCategory)
    let randomMovie =  currentArray.randomElement()
    
    let message = MessageModel(
      role: "user",
      content: """
        generate emoji riddler about \(currentPromptCat) "\(String(describing: randomMovie))"
        question: only emojies no any text
        answers: [
          generate four answer each of them must have answerTitle: string and isCorrect: Bool
        ]
        hint: Provide the correct text for the hint
        """
    )
    
    let body = BodyModel(
      model: "meta-llama/Meta-Llama-3.1-405B-Instruct-Turbo",
      messages: [message]
    )
    
    Task {
      do {
        let response: ChatCompletionResponse = try await webService.postData(
          urlString: api,
          headers: [
            "Authorization": "Bearer \(key)",
            "Content-Type": "application/json"
          ],
          body: body
        )
        
        guard let res = response.choices.first?.message.content else {return}
        guard let parsedGameModel = parseGameModel(from: res) else { return }
        
        isLoading = false
        questionArray.append(parsedGameModel)
        questionDelegate?.updateQuestion()
        indicatorDelegate?.updateLoadingIndicator()
        print(parsedGameModel)
      } catch {
        print("Error fetching data: \(error)")
      }
    }
  }
  
  func getGameCategory(category: Categories)  -> String {
    switch category {
    case .books:
      currentCat = "books"
      currentArray = booksArray
    case .anime:
      currentCat = "anime"
      currentArray = animeArray
    case .movies:
      currentCat = "movies"
      currentArray = movieNames
    }
    
    return currentCat
  }
  
  func fetchNextQuestion() {
    fetchData()
  }
  
  func loadNextQuestion(cat: Categories) -> GameModel? {
    guard currentQuestionIndex < questionArray.count else { return nil }
    let newQuestion = questionArray[currentQuestionIndex]
    currentQuestionIndex += 1
    return newQuestion
  }
  
  func increasePoints() {
    points += 1
    UserDefaults.standard.set(points, forKey: "userPoints")
    delegate?.updateScore(to: points)
  }
  
  func decreaseAttempts() {
    guard attempts > 0 else {
      looserDelegate?.updateLooserState()
      return
    }
    attempts -= 1
    attemptsDelegate?.updateAttpemts(to: attempts)
  }
  
  //GPT 🤝
  func parseGameModel(from input: String) -> GameModel? {
    // Split the input into lines
    let lines = input.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    
    guard lines.count > 1 else { return nil }
    
    // Extract the question
    let question = lines[0]
    
    // Extract the answers
    var answers: [Answer] = []
    for line in lines where line.hasPrefix("1.") || line.hasPrefix("2.") || line.hasPrefix("3.") || line.hasPrefix("4.") {
      // Match answer lines using a regular expression
      let regex = #"(?<index>\d+)\. answerTitle: \"(?<title>[^\"]+)\", isCorrect: (?<isCorrect>true|false)"#
      if let match = line.range(of: regex, options: .regularExpression) {
        let components = line[match].split(separator: ",")
        guard components.count == 2 else { continue }
        
        // Extract the answer title and isCorrect value
        let answerTitle = components[0].split(separator: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
        let isCorrect = components[1].split(separator: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines) == "true"
        
        // Append to the answers array
        answers.append(Answer(answerTitle: answerTitle, isCorrect: isCorrect))
      }
    }
    
    // Extract the hint (optional in this example, so set a default)
    let hint = "Think of classic fairy tales!"
    
    // Return the parsed GameModel
    return GameModel(question: question, answers: answers, hint: hint)
  }
}

