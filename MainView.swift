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
    @State private var isFetching: Bool = false
    @State private var showFetchError = false
    @State private var fetchErrorMessage = ""
    
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
        Group {
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
                                AsyncImage(url: pokemon.spriteURL){ image in
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
        .alert("Fetch failed", isPresented: $showFetchError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(fetchErrorMessage)
        }
    }
    
    private func getPokemon(from id: Int){
        Task { @MainActor in
            guard !isFetching else { return }
            isFetching = true
            do {
                for i in id..<152 {
                    let fetchedPokemon = try await fetchService.fetchPokemon(i)
                    let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
                    fetchRequest.predicate = NSPredicate(
                        format: "pokemonId == %d",
                        fetchedPokemon.id
                    )
                    fetchRequest.fetchLimit = 1
                    let pokemon: Pokemon
                    if let existing = try viewContext.fetch(fetchRequest).first {
                        pokemon = existing
                    } else {
                        pokemon = Pokemon(context: viewContext)
                        pokemon.pokemonId = fetchedPokemon.id
                    }
                    pokemon.name = fetchedPokemon.name
                    pokemon.types = fetchedPokemon.types
                    pokemon.hp = fetchedPokemon.hp
                    pokemon.attack = fetchedPokemon.attack
                    pokemon.defense = fetchedPokemon.defense
                    pokemon.specialAttack = fetchedPokemon.specialAttack
                    pokemon.specialDefense = fetchedPokemon.specialDefense
                    pokemon.speed = fetchedPokemon.speed
                    pokemon.spriteURL = fetchedPokemon.spriteURL
                    pokemon.shinyURL = fetchedPokemon.shinyURL
                    
                }
                
                if viewContext.hasChanges {
                    try viewContext.save()
                }

                // Task 1 done — start Task 2 (sprites) only after pokemon data is saved
                saveSprites()

            } catch {
                fetchErrorMessage = error.localizedDescription
                showFetchError = true
                print("An error occured: \(error)")
                isFetching = false
            }
        }
    }

    /// Task 2 — separate from fetch; runs only when Task 1 calls this after a successful save.
    private func saveSprites() {
        Task { @MainActor in
            defer { isFetching = false }

            do {
                for pokemon in allPokemon {
                    pokemon.sprite = try await URLSession.shared.data(from: pokemon.spriteURL!).0
                    pokemon.shiny = try await URLSession.shared.data(from: pokemon.shinyURL!).0
                    print("Sprites stored \(pokemon.name ?? "")")
                }

                if viewContext.hasChanges {
                    try viewContext.save()
                }
            } catch {
                fetchErrorMessage = error.localizedDescription
                showFetchError = true
                print("Sprites error: \(error)")
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
