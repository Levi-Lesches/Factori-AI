import "recipe_parser.dart";

class ProcessedRecipeParser extends RecipeParser {
	ProcessedRecipeParser() : super("data/processed_recipes.json");

	bool get shouldDownload => !jsonFile.existsSync();

	@override
	Future<Map<String, List<Recipe>>> getRecipes() async {
		final Map<String, List<Recipe>> result = {};
		for (final MapEntry entry in (await getData()).entries) {
			final String name = entry.key;
			final List<Recipe> recipes = [
				for (final Map recipeJson in entry.value)
					Recipe.fromJson(recipeJson)				
			];
			result [name] = recipes;
		}
		return result;
	}
}