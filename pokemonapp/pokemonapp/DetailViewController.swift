//
//  DetailViewController.swift
//  pokemonapp
//
//  Created by Anas Ahmed on 4/21/24.
//

import UIKit
import Nuke

class DetailViewController: UIViewController {
    var pokemon: Pokemon!
    let pokemonColors: [String: UIColor] = [
        "grass": .green,
        "fire": .orange,
        "water": .blue,
        "electric":.yellow,
        "dark":.darkGray,
        "psychic": .systemPink,
        "ground":.brown,
        "ghost":.purple,
        "steel":.gray,
        "flying":.cyan

    ]
    
    @IBOutlet weak var pokemonImageView: UIImageView!
    
    @IBOutlet weak var type: UIButton!
    @IBOutlet weak var pokemonTitle: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pokemonTitle.text = pokemon.name
        
        if let pokemonId = getPokemonId(from: pokemon.url) {
            let imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/shiny/\(pokemonId).gif"
            if let url = URL(string: imageUrl) {
                Nuke.loadImage(with: url, into: pokemonImageView)
            }
        }
        
        if !pokemon.name.isEmpty {
            let pokemonName = pokemon.name.lowercased()
            let apiUrl = "https://pokeapi.co/api/v2/pokemon/\(pokemonName)"
            if let url = URL(string: apiUrl) {
                let session = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    if let error = error {
                        print("Request failed: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let data = data else {
                        print("No data returned from request")
                        return
                    }
                    
                    do {
                        let pokemonDetails = try JSONDecoder().decode(PokemonDetails.self, from: data)
                        if let typeName = pokemonDetails.types.first?.type.name {
                            DispatchQueue.main.async {
                                self?.type.setTitle(typeName.capitalized, for: .normal)
                                if let color = self?.pokemonColors[typeName] {
                                    self?.view.backgroundColor = color
                                }
                            }
                        }

                        // Set other properties accordingly
                    } catch {
                        print("Error decoding JSON data into PokemonDetails: \(error.localizedDescription)")
                    }
                }
                session.resume()
            }
        }
    }
    
    func getPokemonId(from url: String?) -> String? {
        guard let url = url else { return nil }
        let components = url.split(separator: "/")
        return String(components.last ?? "")
    }
}
