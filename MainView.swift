//
//  MainView.swift
//  Po-ke-mon
//
//  Created by Samir Ramic on 20.11.25.
//

import SwiftUI
import CoreData

struct MainView: View {
    private let fetchService = FetchService()
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest<Pokemon>(
        sortDescriptors: [SortDescriptor(\.pokemonId)],
        animation: .default
    )
    private var allPokemon
    
    @FetchRequest<Pokemon>(
        sortDescriptors: [SortDescriptor(\.pokemonId)],
        animation: .default
    )
    private var pokemonResult
   
    @State private var searchText: String = ""
    @State private var filterByFavorite: Bool = false
    
    private var dynamicSearchPredicate: NSPredicate {
        var predicates: [NSPredicate] = []
        //Search predicate
        if !searchText.isEmpty{
            predicates
                .append(NSPredicate(format: "name CONTAINS[c] %@", searchText))
        }
        
        //Filter predicates
        if filterByFavorite {
            predicates.append(NSPredicate(format: "favorite = %d", true))
        }
        
        //Combine predicates
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    

    var body: some View {
        if allPokemon.isEmpty {
            ContentUnavailableView {
                Label("No data", image: .nopokemon)
            } description: {
                Text("Data unavailable. Please try again later.")
            } actions: {
                Button(
                    "Fetch pokemon",
                    systemImage: "antenna.radiowaves.left.and.right"
                ) {
                    getPokemon(from: 1)
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            NavigationStack {
                List {
                    Section {
                        ForEach(pokemonResult) { pokemon in
                            NavigationLink(value: pokemon) {
                                AsyncImage(url: pokemon.sprite){ image in
                                    image.resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 100, height: 100)
                                
                                VStack(alignment: .leading) {
                                    Text(pokemon.name?.capitalized ?? "Unknown")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    
                                    HStack() {
                                        ForEach(
                                            pokemon.types ?? [],
                                            id: \.self
                                        ){ type in
                                            Text(type.description.capitalized)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.black)
                                                .padding(.horizontal, 13)
                                                .padding(.vertical, 5)
                                                .background(
                                                    Color(
                                                        type.description.capitalized
                                                    )
                                                )
                                                .clipShape(.capsule)
                                        }.padding(.vertical)
                                        
                                        if(pokemon.favorite) {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                }
                            }.swipeActions {
                                Button(pokemon.favorite ? "Remove from favorites" : "Add to favorites", systemImage: "star"){
                                    
                                    pokemon.favorite.toggle()
                                    
                                    do {
                                       try viewContext.save()
                                    } catch {
                                        print(error)
                                    }
                                }.tint(pokemon.favorite ? .gray : .yellow)
                            }
                        }
                    } footer: {
                        if allPokemon.count < 151 {
                            ContentUnavailableView {
                                Label("Missing Pokemon", image: .nopokemon)
                            } description: {
                                Text("The fetch was interrupted. Try again?\nFetch them all.")
                            } actions: {
                                Button(
                                    "Fetch pokemon",
                                    systemImage: "antenna.radiowaves.left.and.right"
                                ) {
                                    getPokemon(from: pokemonResult.count + 1)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
                .navigationTitle(Text("Po-ke-mon"))
                .navigationDestination(for: Pokemon.self) { pokemon in
                    PokemonDetail().environmentObject(pokemon)
                }
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Find a Pokemon")
                .autocorrectionDisabled(true)
                .onChange(of: searchText) {
                    pokemonResult.nsPredicate = dynamicSearchPredicate
                }
                .onChange(of: filterByFavorite){
                    pokemonResult.nsPredicate = dynamicSearchPredicate
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            filterByFavorite.toggle()
                        } label: {
                            Label(
                                "Filter by favorites",
                                systemImage: filterByFavorite ? "star.fill" : "star"
                            )
                        }.tint(.yellow)
                    }
                }
            }
        }
    }
    
    private func getPokemon(from id: Int){
        Task {
            do {
                for i in id..<152 {
                    let fetchedPokemon = try await fetchService.fetchPokemon(i)
                    
                    let pokemon = Pokemon(context: viewContext)
                    pokemon.pokemonId = fetchedPokemon.id
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
    MainView()
        .environment(
            \.managedObjectContext,
             PersistenceController.preview.container.viewContext
        )
}
