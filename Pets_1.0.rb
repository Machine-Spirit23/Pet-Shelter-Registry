require './input_functions'
puts("Welcome to the Pet Shelter Registry! \\(^.^)/ \n\n")

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
    new_pet_age  = read_string("What is your pets age?")
    new_pet_colour  = read_string("What is your pets colour?")
    new_pet = Pet.new(new_pet_name, new_pet_breed, new_pet_age.to_i, new_pet_colour)
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


# Searches for a pet by name in the array.
# Takes the pets array as a parameter — loops through every pet checking for a match.
# Uses .downcase on BOTH sides of the comparison so the search is case-insensitive:
#   "echo", "ECHO", "Echo" all match "Echo" in the registry.
#   .downcase only affects the comparison — the actual pet name stays unchanged.
# Uses a boolean flag (found) to track whether any match was found:
#   - Starts as false (nothing found yet)
#   - Flips to true when a match is found
#   - After the loop, if still false, prints an error message
# IMPORTANT: i += 1 must be OUTSIDE the if block — otherwise the loop freezes
#   when a pet doesn't match (i never increments, condition never changes).
def search_pet(pets)
  name = read_string("Who are you looking for?")
  found = false                                     # flag: no match found yet
  i = 0
  while i < pets.length
    if pets[i].name.downcase == name.downcase        # case-insensitive comparison
      print_pet(pets[i])                             # print the matching pet
      puts("\n\n")
      found = true                                   # flip flag — we found at least one
    end
  i += 1                                             # always increment — keeps loop moving
  end

  unless found                                       # unless = "if not"; only runs if found is still false
    puts("#{name}, was not found in the registry.")
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


# Main menu — the heart of the program.
# Uses a post-test loop (begin...end until) so the menu always displays at least once.
# The "finished" flag controls the loop:
#   - Starts as false (keep looping)
#   - Set to true when user picks Exit (option 4)
#   - "end until finished" checks AFTER each pass — exits when finished is true
#
# IMPORTANT: pets array is loaded ONCE before the loop starts (line below).
# All menu options (display, add, search) work on this same array in memory.
# When a new pet is added (option 2), it is:
#   1. Written to the file (write_pet) — so it's saved permanently
#   2. Pushed into the pets array (pets.push) — so it shows up immediately without re-reading the file
# Without pets.push, a newly added pet wouldn't appear until the program restarts.
def menu_main()
    finished = false
    pets = read_pets_from_file("pets.txt")   # load all pets into array ONCE at startup
  begin
    puts("1. Display all pets.")
    puts("2. Add a pet.")
    puts("3. Search for a pet.")
    puts("4. Exit.\n\n")
    choice = read_integer_in_range("Please enter your choice:", 1, 4)
    case choice
    when 1
      display_pet(pets)                       # pass the array to display — menu is the coordinator
    when 2
      new_pet = get_pet()                     # capture-and-pass: get_pet returns a Pet object
      write_pet("pets.txt", new_pet)          # save to file (permanent)
      pets.push(new_pet)                      # add to array (in-memory, keeps array in sync with file)
    when 3
      search_pet(pets)                        # pass the array to search
    when 4
      finished = true                         # flips the flag — loop exits on next "end until" check
    end
  end until finished
end

# Entry point — calls menu_main to start the program.
def main()
  menu_main()
end

main()