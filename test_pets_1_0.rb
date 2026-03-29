# Rites of Verification — Method: Test
# Full program test for Pets_1.0.rb (v1.0 — 6 menu options)
# Tests: display, add, search, delete, edit, ghost pet guard, exit
# 19 tests total

require 'open3'

PETS_FILE = "pets.txt"
BACKUP = "pets_backup.txt"
PROGRAM = "Pets_1.0.rb"

passed = 0
failed = 0
total = 20

# Backup original pets.txt
File.write(BACKUP, File.read(PETS_FILE))

def run_with_input(inputs)
  input_str = inputs.join("\n") + "\n"
  stdout, stderr, status = Open3.capture3("ruby #{PROGRAM}", stdin_data: input_str)
  return stdout, stderr, status
end

def assert(test_name, condition, detail = "")
  if condition
    puts "  PASS: #{test_name}"
    return true
  else
    puts "  FAIL: #{test_name} #{detail}"
    return false
  end
end

puts "=" * 50
puts "Rites of Verification — Pets_1.0.rb (Full)"
puts "=" * 50

# =============================================================
# DISPLAY
# =============================================================

# Test 1: Display all pets (option 1, then exit with 6)
puts "\nTest 1 — Display all pets"
out, err, status = run_with_input(["1", "6"])
all_present = out.include?("Echo") && out.include?("Lola") && out.include?("Choppie") && out.include?("Willow") && out.include?("George") && out.include?("Sasha") && out.include?("Leah")
if assert("All 7 pets shown", all_present)
  passed += 1
else
  failed += 1
end

# =============================================================
# ADD
# =============================================================

# Restore before add tests
File.write(PETS_FILE, File.read(BACKUP))

# Test 2: Add a pet — appears in display
puts "\nTest 2 — Add a pet (display check)"
out, err, status = run_with_input(["2", "Biscuit", "Corgi", "5", "Tan", "1", "6"])
if assert("Biscuit appears in display after adding", out.include?("Biscuit: Corgi, 5, Tan"))
  passed += 1
else
  failed += 1
end

# Test 3: Add a pet — persists in file
puts "\nTest 3 — Add a pet (file persistence)"
file_content = File.read(PETS_FILE)
if assert("Biscuit exists in pets.txt", file_content.include?("Biscuit, Corgi, 5, Tan"))
  passed += 1
else
  failed += 1
end

# =============================================================
# SEARCH
# =============================================================

# Restore before search tests
File.write(PETS_FILE, File.read(BACKUP))

# Test 4: Search — exact match
puts "\nTest 4 — Search exact match"
out, err, status = run_with_input(["3", "Echo", "6"])
if assert("Finds Echo by exact name", out.include?("Echo: Miniature Schnauzer, 7, Black"))
  passed += 1
else
  failed += 1
end

# Test 5: Search — case-insensitive
puts "\nTest 5 — Search case-insensitive"
out, err, status = run_with_input(["3", "echo", "6"])
if assert("Finds Echo with lowercase 'echo'", out.include?("Echo: Miniature Schnauzer, 7, Black"))
  passed += 1
else
  failed += 1
end

# Test 6: Search — not found
puts "\nTest 6 — Search not found"
out, err, status = run_with_input(["3", "Ziggy", "6"])
if assert("Shows not found message", out.include?("was not found in the registry"))
  passed += 1
else
  failed += 1
end

# =============================================================
# DELETE
# =============================================================

# Restore before delete tests
File.write(PETS_FILE, File.read(BACKUP))

# Test 7: Delete — single match
# Flow: delete (4), name "Leah", "No" to delete another, display (1), exit (6)
puts "\nTest 7 — Delete single match"
out, err, status = run_with_input(["4", "Leah", "No", "1", "6"])
removed_msg = out.include?("has been removed")
leah_gone = !out.split("has been removed").last.include?("Leah: Birman")
if assert("Leah removed from display and confirmed", removed_msg && leah_gone)
  passed += 1
else
  failed += 1
end

# Restore before duplicate delete test
File.write(PETS_FILE, File.read(BACKUP))

# Test 8: Delete — duplicate match
# Flow: add (2) second Leah, delete (4), name "Leah", pick #2, "No" to delete another, display (1), exit (6)
puts "\nTest 8 — Delete duplicate match"
out, err, status = run_with_input(["2", "Leah", "Tabby", "3", "Cream", "4", "Leah", "2", "No", "1", "6"])
birman_present = out.split("has been removed").last.include?("Birman")
tabby_gone = !out.split("has been removed").last.include?("Tabby")
if assert("Second Leah (Tabby) removed, first (Birman) remains", birman_present && tabby_gone)
  passed += 1
else
  failed += 1
end

# Restore before delete not-found test
File.write(PETS_FILE, File.read(BACKUP))

# Test 9: Delete — not found
puts "\nTest 9 — Delete not found"
out, err, status = run_with_input(["4", "Ziggy", "6"])
if assert("Shows not found message for delete", out.include?("was not found in the registry"))
  passed += 1
else
  failed += 1
end

# Restore before multi-delete test
File.write(PETS_FILE, File.read(BACKUP))

# Test 10: Delete — multiple pets in a row
# Flow: delete (4), name "Leah", "Yes" to delete another, name "Sasha", "No", display (1), exit (6)
puts "\nTest 10 — Delete multiple pets in a row"
out, err, status = run_with_input(["4", "Leah", "Yes", "Sasha", "No", "1", "6"])
leah_gone = !out.split("Goodbye").first.split("No").last.include?("Leah: Birman")
sasha_gone = !out.split("Goodbye").first.split("No").last.include?("Sasha: German Shepard")
both_removed = out.scan("has been removed").length >= 2
if assert("Leah and Sasha both removed", leah_gone && sasha_gone && both_removed)
  passed += 1
else
  failed += 1
end

# =============================================================
# EDIT
# =============================================================

# Restore before edit tests
File.write(PETS_FILE, File.read(BACKUP))

# Test 11: Edit — change name
# Flow: edit (5), name "Leah", field 1 (name), "Luna", exit sub-menu (5), display (1), exit (6)
puts "\nTest 11 — Edit name"
out, err, status = run_with_input(["5", "Leah", "1", "Luna", "5", "1", "6"])
luna_present = out.split("Goodbye").first.split("Done editing").last.include?("Luna")
leah_gone = !out.split("Goodbye").first.split("Done editing").last.include?("Leah: Birman")
if assert("Leah renamed to Luna", luna_present && leah_gone)
  passed += 1
else
  failed += 1
end

# Restore before edit breed test
File.write(PETS_FILE, File.read(BACKUP))

# Test 12: Edit — change breed
# Flow: edit (5), name "Leah", field 2 (breed), "Ragdoll", exit sub-menu (5), display (1), exit (6)
puts "\nTest 12 — Edit breed"
out, err, status = run_with_input(["5", "Leah", "2", "Ragdoll", "5", "1", "6"])
ragdoll_present = out.split("Goodbye").first.split("Done editing").last.include?("Ragdoll")
if assert("Leah's breed changed to Ragdoll", ragdoll_present)
  passed += 1
else
  failed += 1
end

# Restore before edit age test
File.write(PETS_FILE, File.read(BACKUP))

# Test 13: Edit — change age
# Flow: edit (5), name "Leah", field 3 (age), 2, exit sub-menu (5), display (1), exit (6)
puts "\nTest 13 — Edit age"
out, err, status = run_with_input(["5", "Leah", "3", "2", "5", "1", "6"])
age_changed = out.split("Goodbye").first.split("Done editing").last.include?("Leah: Birman, 2, Red point")
if assert("Leah's age changed to 2", age_changed)
  passed += 1
else
  failed += 1
end

# Restore before edit colour test
File.write(PETS_FILE, File.read(BACKUP))

# Test 14: Edit — change colour
# Flow: edit (5), name "Leah", field 4 (colour), "Blue point", exit sub-menu (5), display (1), exit (6)
puts "\nTest 14 — Edit colour"
out, err, status = run_with_input(["5", "Leah", "4", "Blue point", "5", "1", "6"])
colour_changed = out.split("Goodbye").first.split("Done editing").last.include?("Leah: Birman, 17, Blue point")
if assert("Leah's colour changed to Blue point", colour_changed)
  passed += 1
else
  failed += 1
end

# Restore before edit duplicate test
File.write(PETS_FILE, File.read(BACKUP))

# Test 15: Edit — duplicate match
# Flow: add (2) second Leah, edit (5), name "Leah", pick #2, field 2 (breed), "Ragdoll", exit sub-menu (5), display (1), exit (6)
puts "\nTest 15 — Edit duplicate match"
out, err, status = run_with_input(["2", "Leah", "Tabby", "3", "Cream", "5", "Leah", "2", "2", "Ragdoll", "5", "1", "6"])
ragdoll_present = out.split("Goodbye").first.split("Done editing").last.include?("Ragdoll")
birman_present = out.split("Goodbye").first.split("Done editing").last.include?("Birman")
if assert("Second Leah changed to Ragdoll, first still Birman", ragdoll_present && birman_present)
  passed += 1
else
  failed += 1
end

# Restore before edit not-found test
File.write(PETS_FILE, File.read(BACKUP))

# Test 16: Edit — not found
puts "\nTest 16 — Edit not found"
out, err, status = run_with_input(["5", "Ziggy", "6"])
if assert("Shows not found message for edit", out.include?("was not found in the registry"))
  passed += 1
else
  failed += 1
end

# Restore before multi-edit test
File.write(PETS_FILE, File.read(BACKUP))

# Test 17: Edit — multi-field (change name and age)
# Flow: edit (5), name "Echo", field 1 (name), "Nova", field 3 (age), 3, exit sub-menu (5), display (1), exit (6)
puts "\nTest 17 — Edit multi-field"
out, err, status = run_with_input(["5", "Echo", "1", "Nova", "3", "3", "5", "1", "6"])
both_changed = out.split("Goodbye").first.split("Done editing").last.include?("Nova: Miniature Schnauzer, 3, Black")
if assert("Echo renamed to Nova with age 3", both_changed)
  passed += 1
else
  failed += 1
end

# Restore before exit-without-edit test
File.write(PETS_FILE, File.read(BACKUP))

# Test 18: Edit — exit without making changes
# Flow: edit (5), name "Echo", exit sub-menu (5), display (1), exit (6)
puts "\nTest 18 — Edit exit without changes"
out, err, status = run_with_input(["5", "Echo", "5", "1", "6"])
if assert("Echo unchanged after exiting edit", out.include?("Echo: Miniature Schnauzer, 7, Black"))
  passed += 1
else
  failed += 1
end

# =============================================================
# GHOST PET GUARD
# =============================================================

# Test 19: Ghost pet guard — blank lines in file don't crash
# Write a pets.txt with trailing blank lines, then display
puts "\nTest 19 — Ghost pet guard (blank lines)"
File.write(PETS_FILE, "Echo, Miniature Schnauzer, 7, Black\n\n\n")
out, err, status = run_with_input(["1", "6"])
no_crash = status.exitstatus == 0
echo_shown = out.include?("Echo: Miniature Schnauzer, 7, Black")
if assert("Program handles blank lines without crashing", no_crash && echo_shown)
  passed += 1
else
  failed += 1
end

# =============================================================
# EXIT
# =============================================================

# Restore before exit test
File.write(PETS_FILE, File.read(BACKUP))

# Test 20: Exit — clean exit
puts "\nTest 20 — Exit cleanly"
out, err, status = run_with_input(["6"])
if assert("Exits with status 0 and goodbye", status.exitstatus == 0 && out.include?("Goodbye"))
  passed += 1
else
  failed += 1
end

# =============================================================
# CLEANUP
# =============================================================

# Restore original pets.txt
File.write(PETS_FILE, File.read(BACKUP))
File.delete(BACKUP) if File.exist?(BACKUP)

puts "\n" + "=" * 50
puts "Results: #{passed}/#{total} passed, #{failed}/#{total} failed"
puts "=" * 50
