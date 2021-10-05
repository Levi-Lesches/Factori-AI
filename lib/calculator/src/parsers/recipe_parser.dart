import "dart:convert";
import "dart:io";

import "package:factorio/calculator/data.dart";
export "package:factorio/calculator/data.dart";

abstract class RecipeParser {
	final File jsonFile;

	RecipeParser(String filename) : jsonFile = File(filename);

	Future<dynamic> getData() async => 
		jsonDecode(await jsonFile.readAsString());

	Future<Map<String, List<Recipe>>> getRecipes();
}
