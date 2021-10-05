-- Get the current working directory
current_dir=io.popen"cd":read'*l'
-- Add it to the package path
package.path=package.path..";"..current_dir.."/?.lua"
-- Import the data we need
local data = require "data.recipes"
-- Allows us to export it as json
local json = require "lunajson"
-- Opens the JSON file
file = io.open("data/recipes.json", "w")
-- Sets the output to the JSON file
io.output(file)
-- Encodes the data as JSON and writes it to the JSON file
io.write(json.encode(data))
-- Closes the JSON file
io.close(file)

