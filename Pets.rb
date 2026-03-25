require './input_functions'


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


# Opens the file, loops through all pets using eof?, and prints each one.
# The file is opened and closed here — read_pet just reads from the bookmark.
def read_pets_from_file(pet_filename)
  pet_file = File.new(pet_filename, "r")
    while !pet_file.eof?
      a_pet = read_pet(pet_file)
      print_pet(a_pet)
    end
  pet_file.close()
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


# Asks the user to choose read or write mode.
# Validates input with a while loop — re-prompts until "read" or "write" is entered.
# Then calls the appropriate method.
def pick_mode()
  mode_picker = read_string("Do wish to read the registry or write? [read/write]")
  while mode_picker != "read" && mode_picker != "write"
    puts("Invalid entry please enter 'read' or 'write'\n\n")
    mode_picker = read_string("Do wish to read the registry or write? [read/write]")
  end

  if mode_picker == "read"
    read_pets_from_file("pets.txt")
  else
    new_pet = get_pet()
    write_pet("pets.txt", new_pet)
  end
end


# Entry point — launches [read/write] mode selection.
def main()
  pick_mode()
end

main()