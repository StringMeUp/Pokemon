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

    var body: some View {
        NavigationStack {
            List {
                ForEach(pokemonResult) { pokemon in
                    NavigationLink {
                        if let pName = pokemon.name {
                            Text("Pokemon name:\(pName)")
                        }
                    } label: {
                        if let pName = pokemon.name {
                            Text("Pokemon name:\(pName)")
                        }
                      
                    }
                }
               
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        print("Action")
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
