import requests
import json
import random

# File to store our Pokemon collection
COLLECTION_FILE = "pokemon_collection.json"

# Function to load the Pokemon collection from a file
def load_collection():
    try:
        with open(COLLECTION_FILE, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        return {}

# Function to save the Pokemon collection to a file
def save_collection(collection):
    with open(COLLECTION_FILE, "w") as f:
        json.dump(collection, f, indent=2)

# Function to get a random Pokemon from the API
def get_random_pokemon():
    # Get a list of all Pokemon
    response = requests.get("https://pokeapi.co/api/v2/pokemon?limit=100")
    all_pokemon = response.json()["results"]
    
    # Choose a random Pokemon
    random_pokemon = random.choice(all_pokemon)
    
    # Get details of the chosen Pokemon
    pokemon_url = random_pokemon["url"]
    response = requests.get(pokemon_url)
    pokemon_data = response.json()
    
    # Extract the information we want to save
    pokemon_info = {
        "name": pokemon_data["name"],
        "type": pokemon_data["types"][0]["type"]["name"],
        "ability": pokemon_data["abilities"][0]["ability"]["name"]
    }
    
    return pokemon_info

# Main program
def main():
    # Load the existing collection
    collection = load_collection()
    
    while True:
        # Ask the user if they want to draw a Pokemon
        choice = input("Would you like to draw a Pokemon? (yes/no): ").lower()
        
        if choice == "yes":
            # Get a random Pokemon
            pokemon = get_random_pokemon()
            
            # Check if we already have this Pokemon
            if pokemon["name"] in collection:
                print(f"You already have {pokemon['name']}!")
            else:
                # Add the new Pokemon to our collection
                collection[pokemon["name"]] = pokemon
                print(f"You got a new Pokemon: {pokemon['name']}!")
            
            # Display Pokemon info
            print(f"Name: {pokemon['name']}")
            print(f"Type: {pokemon['type']}")
            print(f"Ability: {pokemon['ability']}")
            
            # Save the updated collection
            save_collection(collection)
            
        elif choice == "no":
            print("Thanks for playing! Goodbye!")
            break
        
        else:
            print("Please enter 'yes' or 'no'.")

# Run the main program
if __name__ == "__main__":
    main()