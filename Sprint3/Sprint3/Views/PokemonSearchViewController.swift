//
//  PokemonSearchViewController.swift
//  Sprint3
//
//  Created by Victor  on 5/10/19.
//  Copyright © 2019 com.Victor. All rights reserved.
//

import Foundation
import UIKit

class PokemonSearchViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var pokemonName: UILabel!
    @IBOutlet weak var pokemonId: UILabel!
    @IBOutlet weak var pokemonTypes: UILabel!
    @IBOutlet weak var pokemonAbilities: UILabel!
    @IBOutlet weak var pokemonImage: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var pokemon: Pokemon? {
        return pokemonController?.pokemon
    }
    
    var pokemonController: PokemonController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        updateViews()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchInput = searchBar.text else { return }
        
        pokemonController?.fetchPokemons(for: searchInput, completion: { (error) in
            if let error = error {
                print(error)
                return
            }
            DispatchQueue.main.async {
                self.updateViews()
            }
        })
    }
    
    func updateViews() {
        
        if let pokemon = pokemon {
            fetchImage(pokemon)
            
            self.title = pokemon.name
            pokemonName.text = pokemon.name
            
            pokemonId.text = "ID: \(String(pokemon.id))"
            
            let types = pokemon.types.map { $0.type.name }.joined(separator: ", ")
            pokemonTypes.text = "Types: \(types)"
            
            let abilities = pokemon.abilities.map { $0.ability.name }.joined(separator: ", ")
            pokemonAbilities.text = "Abilities: \(abilities)"
            
            saveButton.setTitle("Save Pokemon", for: .normal)
        } else {
            self.title = "Pokemon Search"
            pokemonName.text = ""
            pokemonId.text = ""
            pokemonTypes.text = ""
            pokemonAbilities.text = ""
            saveButton.setTitle("", for: .normal)
        }
    }
    
    private func fetchImage(_ pokemon: Pokemon) {
        pokemonController?.getData(url: URL(string: pokemon.sprites.front_default)!, completion: { (data, error) in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                self.pokemonImage.image = UIImage(data: data)
                self.updateViews()
            }
        })
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        pokemonController?.save()
        navigationController?.popViewController(animated: true)
    }
    
    

}