//
//  ViewController.swift
//  pokemonapp
//
//  Created by Anas Ahmed on 4/20/24.
//

import UIKit
import Nuke

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var pokemons: [Pokemon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController did load!")

        
        fetchPokemon()
    }
    
    private func fetchPokemon() {
      guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100&offset=0") else { return }
      let session = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
        if let error = error {
          print(" Request failed: \(error.localizedDescription)")
          return
        }

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
          print(" Server Error: response: \(String(describing: response))")
          return
        }

        guard let data = data else {
          print(" No data returned from request")
          return
        }

        do {
          let pokemonResponse = try JSONDecoder().decode(PokemonResponse.self, from: data)
          let pokemons = pokemonResponse.results
          for pokemon in pokemons {
              print("Fetched Pokémon: \(pokemon.name)")
          }

          DispatchQueue.main.async {
            self?.pokemons = pokemons
            self?.collectionView.reloadData()
            print(" Fetched and stored \(pokemonResponse.results.count) pokemon")
          }
        } catch {
          print(" Error decoding JSON data into Pokemon Response: \(error.localizedDescription)")
        }
      }
      session.resume()
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonCollectionViewCell", for: indexPath) as? PokemonCollectionViewCell else {
        fatalError("Unable to dequeue PokemonCollectionViewCell")
      }

      let pokemon = pokemons[indexPath.item]
      cell.pokemonTitle.text = pokemon.name

      if let pokemonId = getPokemonId(from: pokemon.url) {
        let imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonId).png"
        if let url = URL(string: imageUrl) {
          Nuke.loadImage(with: url, into: cell.pokemonImageView)
        }
      }

      return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      // Define your desired cell size here (e.g., width: 100, height: 100)
      return CGSize(width: 300, height: 300)
    }



    func getPokemonId(from url: String?) -> String? {
      guard let url = url else { return nil }
      let components = url.split(separator: "/")
      return String(components.last ?? "")
    }



    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      print("Selected cell at index \(indexPath.row)")
    }
  }
