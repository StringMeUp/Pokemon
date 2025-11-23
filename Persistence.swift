//
//  Persistence.swift
//  Po-ke-mon
//
//  Created by Samir Ramic on 20.11.25.
//

import CoreData

struct PersistenceController {
    // Db Controller i.e. DAO (Data access object) (controls the Db)
    static let shared = PersistenceController()

    // Preview PC
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

   
        let newPokemon = Pokemon(context: viewContext)
        newPokemon.name = "bulbasaur"
        newPokemon.id = 1
        newPokemon.types = ["Grass", "Poison"]
        newPokemon.hp = 45
        newPokemon.attack = 49
        newPokemon.defense = 49
        newPokemon.specialAttack = 65
        newPokemon.specialDefense = 65
        newPokemon.speed = 45
        newPokemon.sprite = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")
        newPokemon.shinny = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png")
        print("NEW POKEMON\(newPokemon)")
              
        do {
            try viewContext.save()
            print("SAVED\(newPokemon)")
        } catch {
            let nsError = error as NSError
            print(nsError.localizedDescription)
            print("ERROR\(error)")
        }
        return result
    }()

    // The Core Db (Container)
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        print("INI`T")
        container = NSPersistentContainer(name: "Dex")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
