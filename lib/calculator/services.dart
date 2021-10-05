import "dart:io";

import "package:factorio/calculator/constants.dart";
import "package:factorio/calculator/data.dart";
import "package:factorio/calculator/parsers.dart";

import "src/services/downloader.dart";

class Services {
	static final Services instance = Services();

	final Downloader downloader = Downloader();


	Future<void> init() async {
		final ProcessedRecipeParser parser = ProcessedRecipeParser();
		if (parser.shouldDownload) await downloadRecipes();
		final Map<String, List<Recipe>> recipes = await parser.getRecipes();
		ParsedConstants.recipes = filterRecipes(recipes); 
	}

	Future<void> downloadRecipes() async {
		await downloader.downloadRecipes();
		await downloader.exportToJson();
		downloader.dispose();

		final RawRecipeParser parser = RawRecipeParser();
		await parser.saveRecipes();
	}

	Future<void> clearData() async {
		final Directory dataDir = Directory("data");
		if (dataDir.existsSync()) 
			await dataDir.delete(recursive: true);
		await dataDir.create();
		await downloadRecipes();
	}

	Map<String, Recipe> filterRecipes(Map<String, List<Recipe>> recipes) {
		final Map<String, Recipe> result = {};
		for (final MapEntry<String, List<Recipe>> entry in recipes.entries) {
			final String product = entry.key;
			final List<Recipe> recipesForProduct = entry.value;
			final Recipe preferredRecipe = recipesForProduct.length == 1 
				? recipesForProduct.first
				: recipesForProduct.firstWhere(
					(Recipe recipe) => recipe.name == Constants.preferredRecipes [product],
				);
			if (preferredRecipe == null) 
				throw MultipleRecipesError(product);
			result [product] = preferredRecipe;
		}
		return result;
	}

	void dispose() {
		downloader.dispose();
	}
}
