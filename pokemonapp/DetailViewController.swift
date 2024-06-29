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
        "grass": .systemGreen,
        "fire": .orange,
        "water": .blue,
        "electric":.yellow,
        "dark":.darkGray,
        "psychic": .systemPink,
        "ground":.brown,
        "ghost":.purple,
        "steel":.gray,
        "flying":.cyan,
        "fighting":.brown,
        "poison": .systemPurple,
        "bug":.green,
        "normal":.systemGray6,
        "ice":.systemTeal,
        "rock":.systemOrange
    ]
    
    @IBOutlet weak var pokemonImageView: UIImageView!
    
    @IBOutlet weak var type: UIButton!
    @IBOutlet weak var pokemonTitle: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pokemonTitle.text = pokemon.name
        pokemonImageView.backgroundColor = .gray
        if let pokemonId = getPokemonId(from: pokemon.url) {
            let imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/shiny/\(pokemonId).gif"
            if let url = URL(string: imageUrl) {
                Nuke.loadImage(with: url, into: pokemonImageView) { result in
                    switch result {
                    case .success(let response):
                        self.pokemonImageView.image = response.image
                        // Make image circular
                        self.makeImageCircular(imageView: self.pokemonImageView)
                    case .failure(let error):
                        print("Failed to load image: \(error)")
                    }
                }
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        makeImageCircular(imageView: pokemonImageView)
    }

    func makeImageCircular(imageView: UIImageView) {
        let diameter = imageView.frame.size.width
        
        imageView.layer.cornerRadius = diameter / 2
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill // Fill the circular bounds without stretching
        
        // Optionally, add a border to the circular image view
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = UIColor.white.cgColor
    }

    func getPokemonId(from url: String?) -> String? {
        guard let url = url else { return nil }
        let components = url.split(separator: "/")
        return String(components.last ?? "")
    }
}
