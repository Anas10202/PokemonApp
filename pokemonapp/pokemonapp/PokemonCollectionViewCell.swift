//
//  PokemonCollectionViewCell.swift
//  pokemonapp
//
//  Created by Anas Ahmed on 4/20/24.
//

import UIKit
import Nuke
class PokemonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pokemonImageView: UIImageView!
    
    @IBOutlet weak var pokemonTitle: UILabel!
    
    
    
    func setup(with pokemon: Pokemon) {
        pokemonTitle.text = pokemon.name
        if let imageUrl = pokemon.imageUrl {
            Nuke.loadImage(with: imageUrl as! ImageRequestConvertible, into: pokemonImageView)
        } else {
            // Handle missing image URL (optional placeholder or error message)
        }
    }
}
