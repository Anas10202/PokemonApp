//
//  ViewController.swift
//  pokemonapp
//
//  Created by Anas Ahmed on 4/20/24.
//

import UIKit
import Nuke


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var pokemons: [Pokemon] = []
    var filteredPokemons: [Pokemon] = []
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController did load!")
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchPokemon()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else { return }
        
        // Get the selected movie from the movies array using the selected index path's row
        let selectedPokemon = pokemons[selectedIndexPath.row]
        
        // Get access to the detail view controller via the segue's destination. (guard to unwrap the optional)
        guard let detailViewController = segue.destination as? DetailViewController else { return }
        
        detailViewController.pokemon = selectedPokemon
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
                    self?.filteredPokemons = pokemons
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
        
        if !pokemon.name.isEmpty {
            let pokemonName = pokemon.name
            let apiUrl = "https://pokeapi.co/api/v2/pokemon/\(pokemonName.lowercased())"
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
                        // Access the type information from pokemonDetails and set the cell's background color
                        
                        if let typeName = pokemonDetails.types.first?.type.name, let color = self?.pokemonColors[typeName] {
                            DispatchQueue.main.async {
                                cell.backgroundColor = color
                            }
                        } else {
                            DispatchQueue.main.async {
                                cell.backgroundColor = .gray // Default color if type is not found
                            }
                        }
                    } catch {
                        print("Error decoding JSON data into PokemonDetails: \(error.localizedDescription)")
                    }
                }
                session.resume()
            }
        } else {
            cell.backgroundColor = .gray // Default color if no name is found
        }
        
        
        if let pokemonId = getPokemonId(from: pokemon.url) {
            let imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/shiny/\(pokemonId).gif"
            if let url = URL(string: imageUrl) {
                Nuke.loadImage(with: url, into: cell.pokemonImageView)
            }
        }
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = collectionView.bounds.width / 3 - 10 // Adjust padding as needed
        return CGSize(width: itemSize, height: itemSize)
    }
    
    
    
    func getPokemonId(from url: String?) -> String? {
        guard let url = url else { return nil }
        let components = url.split(separator: "/")
        return String(components.last ?? "")
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected cell at index \(indexPath.row)")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let searchView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SearchBar", for: indexPath) as! SearchBarView
        print("searchbar")
        searchView.backgroundColor = .red
        if let searchBar = searchView.searchBar {
            searchBar.barTintColor = .red
            searchBar.backgroundColor = .red
            
            // Change the search text field's background color
            if let textField = searchBar.value(forKey: "searchField") as? UITextField {
                textField.backgroundColor = .white
                
                // Change the search icon's background color
                if let searchIcon = textField.leftView as? UIImageView {
                    searchIcon.tintColor = .red
                }
            }
            
            // Customize the cancel button
            if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
                cancelButton.backgroundColor = .red
                cancelButton.setTitleColor(.white, for: .normal)
            }
            
            searchBar.layer.borderWidth = 1
            searchBar.layer.borderColor = UIColor.red.cgColor
            
        }
        
        
        return searchView
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            pokemons = filteredPokemons
        } else {
            pokemons = filteredPokemons.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        collectionView.reloadData()
    }
}
