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
  let types: [PokemonType]?
  let url: String?
  var imageUrl: String?

  enum CodingKeys: String, CodingKey {
    case name
    case types
    case url
  }

}

struct PokemonType: Decodable {
    let slot: Int
    let type: Type
}

struct Type: Decodable {
    let name: String
    let url: String
}
struct PokemonDetails: Decodable {
    let types: [PokemonType]
}
