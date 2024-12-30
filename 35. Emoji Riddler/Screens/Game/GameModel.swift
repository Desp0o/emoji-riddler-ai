//
//  GameModel.swift
//  35. Emoji Riddler
//
//  Created by Despo on 29.12.24.
//
import SwiftUI

struct GameModel: Hashable, Identifiable, Codable, Sendable {
  var id = UUID()
  let question: String
  let answers: [Answer]
  let hint: String
}

struct Answer: Hashable, Identifiable, Codable, Sendable {
  var id = UUID()
  let answerTitle: String
  let isCorrect: Bool
}



struct BodyModel: Codable {
    let model: String
    let messages: [MessageModel]
}

struct MessageModel: Codable {
    let role: String
    let content: String
}


struct ChatCompletionResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let prompt: [String]?
    let choices: [Choice]
    let usage: Usage?
}


struct Choice: Codable {
    let finishReason: String
    let seed: UInt64?
    let logprobs: String?
    let index: Int
    let message: Message

    enum CodingKeys: String, CodingKey {
        case finishReason = "finish_reason"
        case seed, logprobs, index, message
    }
}

struct Message: Codable {
    let role: String
    let content: String
    let toolCalls: [String]?

    enum CodingKeys: String, CodingKey {
        case role, content
        case toolCalls = "tool_calls"
    }
}

struct Usage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

