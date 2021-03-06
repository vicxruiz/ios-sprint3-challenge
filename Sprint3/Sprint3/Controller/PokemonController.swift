//
//  PokemonController.swift
//  Sprint3
//
//  Created by Victor  on 5/10/19.
//  Copyright © 2019 com.Victor. All rights reserved.
//

import Foundation

class PokemonController {
    
    //MARK: Properties
    
    var pokemons: [Pokemon] = []
    var pokemon: Pokemon?
    let baseURL = URL(string: "https://pokeapi.co/api/v2")!
    
    private enum HTTPMethod: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }
    
    //MARK: Methods

    //method to save to array
    func save() {
        guard let pokemon = pokemon else { return }
        pokemons.append(pokemon)
        pokemons = pokemons.sorted { $0.id < $1.id }
        self.pokemon = nil
        saveToPersistentStore()
    }
    
    //method to delete pokemon
    func delete(pokemon: Pokemon) {
        guard let index = pokemons.index(of: pokemon) else { return }
        pokemons.remove(at: index)
        saveToPersistentStore()
    }
    
    //method to fetch data from url
    func fetchPokemons(for name: String, completion: @escaping (Error?) -> Void) {
        //creating search url
        var searchURL = baseURL.appendingPathComponent("pokemon")
        searchURL = searchURL.appendingPathComponent(name.lowercased())
        
        var request = URLRequest(url: searchURL)
        request.httpMethod = HTTPMethod.get.rawValue
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            //error handling for fetched data
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(NSError())
                return
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                //logic to decode and store data
                let data = try jsonDecoder.decode(Pokemon.self, from: data)
                self.pokemon = data
                completion(nil)
            } catch {
                NSLog("Error while decoding pokemon: \(error)")
                completion(error)
                return
            }
            }.resume()
    }
    
    
    func getData(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let jsonUrl = url
        var request = URLRequest(url: jsonUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            completion(data, error)
            }.resume()
    }
    
    //saves data to url in document
    func saveToPersistentStore() {
        let plistEncoder = PropertyListEncoder()
        do {
            let data = try plistEncoder.encode(pokemons)
            guard let shoppingItemsFileURL = pokemonFileURL else { return }
            try data.write(to: shoppingItemsFileURL)
        } catch {
            NSLog("Error enconding shopping items: \(error)")
        }
        
    }
    
    //loads data from url
    func loadFromPersistentStore() {
        do {
            guard let pokemonFileURL = pokemonFileURL,
                FileManager.default.fileExists(atPath: pokemonFileURL.path) else  { return }
            let data = try Data(contentsOf: pokemonFileURL)
            let plistDecoder = PropertyListDecoder()
            self.pokemons = try plistDecoder.decode([Pokemon].self, from: data)
        } catch {
            print(error)
        }
    }
    
    
    //creates url path 
    var pokemonFileURL: URL? {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = "pokemons.plist"
        return documentDirectory?.appendingPathComponent(fileName)
    }
    
    
    
}
