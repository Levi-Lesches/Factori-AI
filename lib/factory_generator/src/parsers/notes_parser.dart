import "package:factorio/factory_generator/constants.dart";

/// Parses data from the notes file.
class NotesParser {
	/// Finds the cells and their relevant lines in the file.
	static Map<String, int> getCellsAndLines(List<String> lines) => {
		for (final MapEntry<int, String> entry in lines.asMap().entries) 
			if (
				!entry.value.startsWith("  ") &&  // not indented
				entry.value.isNotEmpty        &&  // not an empty line
				!entry.value.startsWith("#")      // not a comment
			) 
				entry.value.replaceAll(":", "").toLowerCase(): entry.key
	};

	/// Finds train routes for each cell.
	static Map<String, Set<String>> getTrainRoutes(
		Map<String, int> factories, 
		List<String> lines
	) {
		final Map<String, Set<String>> imports = {};
		final Map<String, int> priorities = {};
		for (final MapEntry<String, int> entry in factories.entries) {
			bool foundImportTag = false;
			final Set<String> products = {};  
			for (final String line in lines.sublist(entry.value)) {
				if (line.startsWith("  imports")) {
					foundImportTag = true;
					priorities [entry.key] = int.parse(
						line.substring(line.indexOf("priority") + "priority".length).trim()
					);
				} else if (line.isEmpty) {
					if (foundImportTag) {
						imports [entry.key] = products;
						break;
					} else {
						throw AssertionError("Could not find imports for ${entry.key}");
					}
				} else if (foundImportTag) {
					// Try to identify the import using 4 methods: 
					// 
					// 1. Ignore everything after the comma
					// 2. Convert to lower case
					// 3. Check if it's a basic resource (land-locked)
					// 4. Check if a factory registered it as an export
					// 5. Check if it's listed under an alias
					String product = line.trimLeft();

					// Step 1. Take away everything after the comma
					final int indexOfColon = product.indexOf(":");
					if (indexOfColon != -1) {
						product = product.substring(0, indexOfColon);
					}

					// Step 2. Get rid of case sensitivity
					product = product.toLowerCase();

					// Step 3. Maybe we don't even need it at all
					if (Constants.excludedImports.contains(product)) {
						continue;
					}

					// Step 4. If a factory produces this product
					if (factories.containsKey(product)) {
						products.add(product);
					} else {

						// Step 5. Must find an alias
						bool found = false;
						for (
							final MapEntry<String, List<String>> entry in 
							Constants.aliases.entries
						) {
							if (entry.value.contains(product)) {
								products.add(entry.key);
								found = true;
								break;
							}
						}

						// Error
						if (!found) {
							throw AssertionError(
								"Could not find import <$product> for <${entry.key}>"
							);
						}
					}
				}
			}
		}

		ParsedConstants.priorities = priorities;
		return imports;
	}
}
