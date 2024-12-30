//
//  MainViewModel.swift
//  35. Emoji Riddler
//
//  Created by Despo on 29.12.24.
//

enum Categories: String {
    case books
    case movies
    case anime
}

final class CategoryViewModel {
    var categoryArray: [Categories] = [.books, .movies, .anime]
}
