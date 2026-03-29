# Pet Shelter Registry — Version 1.0
# Author: Fotis Markou
# ============================================================
# Version History:
#   v1.0 — March 2026
#     - Menu system replacing pick_mode (begin...end until loop)
#     - Array-based storage (read once, use everywhere)
#     - Search with case-insensitive matching (.downcase)
#     - Delete with duplicate handling
#     - Edit with field sub-menu (name, breed, age, colour)
#     - Multi-delete loop (Yes/No prompt)
#     - find_pet shared method (used by search, delete, edit)
#     - Ghost pet guard in read_pets_from_file (skips blank lines)
#     - File rewrite for delete and edit operations ("w" mode)
#     - Refactored for modularity (shared methods, reduced duplication)
#
#   v0 — Pets.rb (original)
#     - Read or write only (pick_mode)
#     - Single-use: one operation then exit
# ============================================================

require './input_functions'
puts("Welcome to the Pet Shelter Registry! \\(^.^)/ \n\n What would you like to do?")

# Pet class — stores a single pet's details (name, breed, age, colour).
# Used as the composite data type for both reading from and writing to file.
class Pet
  attr_accessor :name, :breed, :age, :colour

  def initialize(name, breed, age, colour)
    @name = name
    @breed = breed
    @age = age
    @colour = colour
  end
end


# Reads one pet from an already-open file. Expects comma-separated format:
# "Name, Breed, Age, Colour"
# .split takes a string >> chops it >> stores into array parts[0-3]
# The argument works like a regex and can have regex inputs!
# Returns a Pet object.
def read_pet(pet_file)
   parts = pet_file.gets.chomp.split(", ")
   a_pet = Pet.new(parts[0], parts[1], parts[2].to_i, parts[3])
   return a_pet
end


# Displays a single pet's details to the terminal.
# Takes a Pet object — does not touch files.
def print_pet(a_pet)
  puts("#{a_pet.name}: #{a_pet.breed}, #{a_pet.age}, #{a_pet.colour}")
end


# Displays ALL pets in the array to the terminal.
# Takes an array of Pet objects as a parameter — does not read from file.
# Loops through the array using an index counter (i) and .length.
# Calls print_pet for each individual pet — keeps single-pet printing separate.
# The array is passed in from the menu — this method doesn't know where it came from.
def display_pet(pets)
    i = 0
  while i < pets.length          # .length returns the number of items; use < not <= because indices start at 0
    print_pet(pets[i])            # pets[i] grabs the Pet object at position i, passes it to print_pet
    i += 1
  end
  puts("\n\n")                    # blank line after the list for readability
end

# Opens the file, loops through all pets using eof?, and prints each one.
# The file is opened and closed here — read_pet just reads from the bookmark.
# VERSION 1.0 CHANGE: No longer prints pets directly.
# Instead, builds an array of Pet objects and returns it.
# The array is then used by display_pet, search_pet, and future features (delete, edit).
# This is the "read once, use many times" pattern — the file is only opened once at startup.
def read_pets_from_file(pet_filename)
  pets=[]                         # empty array — will hold all Pet objects from the file
  pet_file = File.new(pet_filename, "r")
    until pet_file.eof?           # until = mirror of while; loops while condition is false ("until end of file")
      a_pet = read_pet(pet_file)  # read_pet reads one line, builds one Pet object, returns it
      next if a_pet.name.nil? || a_pet.name.empty?  # skip blank lines — prevents ghost pets with nil names
      pets.push(a_pet)            # .push adds the Pet object to the end of the array
    end
  pet_file.close()
  return pets                     # returns the full array to whoever called this method
end


# Collects pet details from user input (4 prompts, one per attribute).
# Returns a new Pet object. Age is converted to integer with .to_i.
def get_pet()
    new_pet_name = read_string("What is your pets name? ")
    new_pet_breed = read_string("What is your pets breed?")
    new_pet_age  = read_integer("What is your pets age?")
    new_pet_colour  = read_string("What is your pets colour?")
    new_pet = Pet.new(new_pet_name, new_pet_breed, new_pet_age, new_pet_colour)
  return new_pet
end


# Writes one pet to file in comma-separated format.
# Uses "a" (append) mode so existing entries are preserved.
# Opens and closes the file internally — only needs the filename and a Pet object.
def write_pet(pet_filename, new_pet)
  pet_file = File.new(pet_filename, "a")
  pet_file.puts("#{new_pet.name}, #{new_pet.breed}, #{new_pet.age}, #{new_pet.colour}")
  pet_file.close()
end


# Shared method — searches the pets array by name and handles duplicate selection.
# Used by search_pet, delete_pet, and edit_pet to avoid repeating the same pattern.
# Returns the INDEX (position) of the chosen pet in the pets array, or -1 if not found.
# Three cases:
#   - Multiple matches: shows a numbered list, lets user pick → returns chosen position
#   - Single match: returns that position directly
#   - No match: returns -1
# The prompt parameter lets each caller customise the question (e.g. "remove" vs "edit").
def find_pet(pets, prompt)
  name = read_string(prompt)
  dupes = []                                         # stores INDICES (positions) of matching pets

  i = 0
  while i < pets.length
    if pets[i].name.downcase == name.downcase         # case-insensitive match
      dupes.push(i)                                   # save the position in the pets array
    end
  i += 1
  end

  if dupes.length >= 2                                # multiple pets share the same name
    puts("#{dupes.length} entries found which #{name} did you want to pick?")
    i = 0
    while i < dupes.length
      puts("#{i + 1}.")                               # display as 1-based (human-friendly)
      print_pet(pets[dupes[i]])                        # dupes[i] holds the position in pets array
      i += 1
    end
    choice = read_integer_in_range("Which one?", 1, dupes.length)
    return dupes[choice - 1]                           # convert user's 1-based pick to pets array position

  elsif dupes.length == 1                              # exactly one match — no need to ask
    return dupes[0]

  else                                                 # no match found
    puts("#{name}, was not found in the registry.")
    return -1
  end
end


# Searches for a pet by name and displays the result.
# Uses find_pet for the search — if found, prints the pet's details.
# search_pet is the only caller that doesn't modify anything — display only.
def search_pet(pets)
  target = find_pet(pets, "Who are you looking for?")
  if target != -1
    print_pet(pets[target])
    puts("\n\n")
  end
end

# VERSION 1.0 CHANGE: pick_mode replaced by menu_main (below).
# pick_mode only allowed read OR write, then exited.
# menu_main loops until the user chooses to exit, allowing multiple operations per session.
# Original pick_mode preserved below as a comment for version history.

#def pick_mode()
#  mode_picker = read_string("Do wish to read the registry or write? [read/write]")
#  while mode_picker != "read" && mode_picker != "write"
#    puts("Invalid entry please enter 'read' or 'write'\n\n")
#    mode_picker = read_string("Do wish to read the registry or write? [read/write]")
#  end
#
#  if mode_picker == "read"
#    read_pets_from_file("pets.txt")
#  else
#    new_pet = get_pet()
#    write_pet("pets.txt", new_pet)
#  end
#end


# Rewrites the entire pets file from the current array.
# Uses "w" (write) mode — wipes the file clean and writes everything fresh.
# This is the only way to "delete" or "edit" in a text file — you can't
# surgically remove or change one line, so you rewrite the whole thing.
# Called by delete_pet (and future edit_pet) after modifying the array.
def rewrite_pets_file(pet_filename, pets)

    pet_file = File.new(pet_filename, "w")  # "w" = write mode — creates a blank file (overwrites existing)

    i = 0
    while i < pets.length
    pet_file.puts("#{pets[i].name}, #{pets[i].breed}, #{pets[i].age}, #{pets[i].colour}")
    i += 1
    end
    pet_file.close()

end


# Deletes a pet from the array and rewrites the file.
# Uses find_pet to locate the target — all search and duplicate logic is handled there.
# If find_pet returns a valid position, deletes the pet and rewrites the file.
# If find_pet returns -1, the "not found" message was already printed by find_pet.
def delete_pet(pet_filename, pets)
  target = find_pet(pets, "Which pet would you like to remove?")

  if target != -1
    puts("#{pets[target].name} has been removed from the registry.")
    pets.delete_at(target)
    rewrite_pets_file(pet_filename, pets)

    again = read_string("Would you like to delete another pet? [Yes/No]")
    while again.downcase == "yes"
      target = find_pet(pets, "Which pet would you like to remove?")
      if target != -1
        puts("#{pets[target].name} has been removed from the registry.")
        pets.delete_at(target)
        rewrite_pets_file(pet_filename, pets)
      end
      again = read_string("Would you like to delete another pet? [Yes/No]")
    end
  end

end


# Edits a pet's attributes in the array and rewrites the file.
# Uses find_pet to locate the target — all search and duplicate logic is handled there.
# After identifying the target pet, a sub-menu lets the user change
# one or more fields before exiting. The file is only rewritten if
# at least one edit was made.
# If find_pet returns -1, the "not found" message was already printed by find_pet.
def edit_pet(pet_filename, pets)
  target = find_pet(pets, "Which pet would you like to edit?")
  edited = false

  if target != -1                                      # only show sub-menu if we found a pet
    begin
      puts("What field would you like to edit?")
      puts("1. Name.")
      puts("2. Breed.")
      puts("3. Age.")
      puts("4. Colour.")
      puts("5. Done editing.")
      field_edit = read_integer_in_range("Please enter your choice:", 1, 5)
      case field_edit
      when 1
        new_name = read_string("What is the new name?")
        pets[target].name = new_name
        edited = true
      when 2
        new_breed = read_string("What is the new breed?")
        pets[target].breed = new_breed
        edited = true
      when 3
        new_age = read_integer("What is the new age?")
        pets[target].age = new_age
        edited = true
      when 4
        new_colour = read_string("What is the new colour?")
        pets[target].colour = new_colour
        edited = true
      end
    end until field_edit == 5
  end

  if edited                                            # only rewrite the file if something was actually changed
    rewrite_pets_file(pet_filename, pets)
  end

end

# Main menu — the heart of the program.
# Uses a post-test loop (begin...end until) so the menu always displays at least once.
# The "finished" flag controls the loop:
#   - Starts as false (keep looping)
#   - Set to true when user picks Exit (option 6)
#   - "end until finished" checks AFTER each pass — exits when finished is true
#
# IMPORTANT: pets array is loaded ONCE before the loop starts (line below).
# All menu options work on this same array in memory.
# When a new pet is added (option 2), it is:
#   1. Written to the file (write_pet) — so it's saved permanently
#   2. Pushed into the pets array (pets.push) — so it shows up immediately without re-reading the file
# Without pets.push, a newly added pet wouldn't appear until the program restarts.
# When a pet is deleted (option 4), delete_pet handles both the array and file rewrite.
def menu_main()
  pet_filename = "pets.txt"
  finished = false
  pets = read_pets_from_file(pet_filename)   # load all pets into array ONCE at startup
    begin
      puts("1. Display all pets.")
      puts("2. Add a pet.")
      puts("3. Search for a pet.")
      puts("4. Delete a pet entry.")
      puts("5. Edit a pet entry.")
      puts("6. Exit.\n\n")
      choice = read_integer_in_range("Please enter your choice:", 1, 6)
      case choice
      when 1
        display_pet(pets)                       # pass the array to display — menu is the coordinator
      when 2
        new_pet = get_pet()                     # capture-and-pass: get_pet returns a Pet object
        write_pet(pet_filename, new_pet)          # save to file (permanent)
        pets.push(new_pet)                      # add to array (in-memory, keeps array in sync with file)
      when 3
        search_pet(pets)                        # pass the array to search
      when 4
        delete_pet(pet_filename, pets)
      when 5 
        edit_pet(pet_filename, pets)
      when 6
        puts("Goodbye (-_-)zzz")
        finished = true                         # flips the flag — loop exits on next "end until" check
      end
    end until finished
end

# Entry point — calls menu_main to start the program.
def main()
  menu_main()
end

main()