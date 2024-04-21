//
//  ViewController.swift
//  pokemonapp
//
//  Created by Anas Ahmed on 4/20/24.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var pokemons: [Pokemon] = []
    
    override func viewDidLoad() {
        collectionView.register(UINib(nibName: "PokemonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        fetchPokemon()
    }
    
    private func fetchPokemon() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100&offset=0") else { return }
        let session = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("🚨 Request failed: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("🚨 Server Error: response: \(String(describing: response))")
                return
            }
            
            guard let data = data else {
                print("🚨 No data returned from request")
                return
            }
            
            do {
                let pokemonResponse = try JSONDecoder().decode(PokemonResponse.self, from: data)
                let pokemons = pokemonResponse.results
                for pokemon in pokemons {
                    print("Fetched Pokémon: \(pokemon.name)")
                    
                }

                DispatchQueue.main.async {
                    self?.pokemons = pokemonResponse.results
                    self?.collectionView.reloadData()
                    print("🍏 Fetched and stored \(pokemonResponse.results.count) pokemon")
                }
            } catch {
                print("🚨 Error decoding JSON data into Pokemon Response: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? PokemonCollectionViewCell else {
            fatalError("Unable to dequeue PokemonCollectionViewCell")
        }
        cell.setup(with: pokemons[indexPath.row])
        return cell
    }
}
