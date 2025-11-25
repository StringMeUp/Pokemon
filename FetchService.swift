//
//  FetchService.swift
//  Po-ke-mon
//
//  Created by Samir Ramic on 25.11.25.
//

import Foundation

struct FetchService {
    enum FetchError : Error {
        case badResponse
    }
    
    private let baseUrl = URL(string: "https://pokeapi.co/api/v2/pokemon")!
    
    func fetchPokemon(_ id: Int) async throws -> FetchedPokemon {
        let fetchUrl = baseUrl.appending(path: String(id))
        let (data, response) = try await URLSession.shared.data(from: fetchUrl)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200
        else { throw FetchError.badResponse }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let pokemon = try decoder.decode(FetchedPokemon.self, from: data)
        
        print("Fetched pokemon with id: \(id) and name: \(pokemon.name)")
        
        return pokemon
    }
}
