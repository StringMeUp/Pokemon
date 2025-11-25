//
//  ContentView.swift
//  Po-ke-mon
//
//  Created by Samir Ramic on 20.11.25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.attack, ascending: true)],
        animation: .default)
    private var pokemonResult: FetchedResults<Pokemon>
    private let fetchService = FetchService()

    var body: some View {
        NavigationStack {
            List {
                ForEach(pokemonResult) { pokemon in
                    NavigationLink {
                        if let pName = pokemon.name {
                            Text("Pokemon name:\(pName)")
                        }
                    } label: {
                        Text("Pokemon name: \(pokemon.name ?? "Unknown")")
                    }
                }
               
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                       fetchPokemon()
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    private func fetchPokemon(){
        Task {
            do {
                for id in 1..<152{
                    let fetchedPokemon = try await fetchService.fetchPokemon(id)
                    
                    let pokemon = Pokemon(context: viewContext)
                    pokemon.id = fetchedPokemon.id
                    pokemon.name = fetchedPokemon.name
                    pokemon.types = fetchedPokemon.types
                    pokemon.hp = fetchedPokemon.hp
                    pokemon.attack = fetchedPokemon.attack
                    pokemon.defense = fetchedPokemon.defense
                    pokemon.specialAttack = fetchedPokemon.specialAttack
                    pokemon.specialDefense = fetchedPokemon.specialDefense
                    pokemon.speed = fetchedPokemon.speed
                    pokemon.sprite = fetchedPokemon.sprite
                    pokemon.shiny = fetchedPokemon.shiny
                    
                    try viewContext.save()
                }
            } catch {
                print("An error occured: \(error)")
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
