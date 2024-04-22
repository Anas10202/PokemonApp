//
//  Pokemon.swift
//  pokemonapp
//
//  Created by Anas Ahmed on 4/20/24.
//

import Foundation


struct PokemonResponse: Decodable {
  let count: Int
  let next: String?
  let previous: String?
  let results: [Pokemon]
}

struct Pokemon: Decodable {
  let name: String
  let url: String?
  var imageUrl: String?

  enum CodingKeys: String, CodingKey {
    case name
    case url
  }
}
