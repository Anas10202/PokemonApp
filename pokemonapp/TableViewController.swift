//
//  TableViewController.swift
//  pokemonapp
//
//  Created by Anas Ahmed on 4/22/24.
//

import UIKit
import Nuke

class TableViewController: UIViewController, UITableViewDataSource {
    var pokemons: [Pokemon] = []
    
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
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "PokemontableViewCell")
        tableView.dataSource = self
        fetchPokemon()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        let pokemon = pokemons[indexPath.row]
        
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
        
        // Set background color based on type, if available

        
        return cell
    }
    
    private func fetchPokemon() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100&offset=0") else { return }
        let session = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Request failed: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server Error: response: \(String(describing: response))")
                return
            }
            
            guard let data = data else {
                print("No data returned from request")
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
                    self?.tableView.reloadData()
                    print("Fetched and stored \(pokemonResponse.results.count) pokemon")
                }
            } catch {
                print("Error decoding JSON data into Pokemon Response: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
    func getPokemonId(from url: String?) -> String? {
        guard let url = url else { return nil }
        let components = url.split(separator: "/")
        return String(components.last ?? "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "tablesegue" else {
            return
        }
        
        // Ensure a row is selected
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
            return
        }
        
        // Get the selected Pokémon from the pokemons array using the selected index path
        let selectedPokemon = pokemons[selectedIndexPath.row]
        
        // Get access to the detail view controller via the segue's destination
        guard let detailViewController = segue.destination as? DetailViewController else {
            return
        }
        
        // Pass the selected Pokémon to the detail view controller
        detailViewController.pokemon = selectedPokemon
    }
}
