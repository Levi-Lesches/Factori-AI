import "dart:convert";
import "dart:io";

import "recipe_parser.dart";

class RawRecipeParser extends RecipeParser {
	RawRecipeParser() : super("data/recipes.json");

	Iterable<Item> getItems(Iterable entries) sync* {
		for (final entry in entries) {
			if (entry is Map) {
				final String name = entry ["name"];
				final int amount = entry["amount"];
				yield Item(name, amount);
			} else if (entry is List) {
				final String name = entry [0];
				final int amount = entry [1];
				yield Item(name, amount);
			} else {
				throw FormatException(
					"Unknown item format: ${entry.runtimType}", 
					entries,
				);
			}
		}
	}

	Iterable<Item> getProducts(Map<String, dynamic> json) => 
		json.containsKey("result")
			? [Item(json ["result"], json["result_count"] ?? 1)]
			: getItems(json ["results"]);

	List<Item> getIngredients(Map<String, dynamic> json) => 
		getItems(json ["ingredients"]).toList();

	@override
	Future<Map<String, List<Recipe>>> getRecipes() async {
		final List data = await getData();
		final Map<String, List<Recipe>> recipes = {};

		for (final entry in data) {
			Map<String, dynamic> json = Map<String, dynamic>.from(entry);
			if (json.containsKey("normal")) {
				json = json ["normal"];
			}
			final String name = json ["name"];
			final num time = json ["energy_required"] ?? 0.5;
			final Iterable<Item> products = getProducts(json);
			final List<Item> ingredients = getIngredients(json);
			for (final Item product in products) {
				final Recipe recipe = Recipe(
					time: time,
					name: name,
					product: product,
					ingredients: ingredients,
				);
				recipes.putIfAbsent(product.name, () => []);
				recipes [product.name].add(recipe);
			}
		}
		return recipes;
	}

	Future<void> saveRecipes() async {
		final Map<String, List<Recipe>> recipes = await getRecipes();
		final File file = File("data/processed_recipes.json");
		final String json = jsonEncode(
			recipes, 
			toEncodable: (obj) => obj is Recipe ? obj.json : obj.toString()
		);
		return file.writeAsString(json);
	}
}
