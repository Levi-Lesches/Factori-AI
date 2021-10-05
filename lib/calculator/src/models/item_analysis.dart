import "package:factorio/calculator/constants.dart";
import "package:factorio/calculator/data.dart";

class ItemAnalysis {
	static int getFactoryCount(Item item, {double craftingSpeed = 5.5}) {
		final String name = item.name;
		final Recipe recipe = ParsedConstants.recipes [name];
		final int amountPerRecipe = recipe.product.amount;
		final num time = recipe.time;
		return ((item.amount * time) / (amountPerRecipe * craftingSpeed)).ceil();
	}

	static List<Item> getIngredients(List<Item> items) {
		final Map<String, num> ingredients = {};
		for (final Item item in items) {
			final Map<String, num> subingredients = ItemNode(item).collapse();
			for (final MapEntry<String, num> entry in subingredients.entries) {
				final String ingredientName = entry.key;
				final num ingredientAmount = entry.value;
				ingredients.putIfAbsent(ingredientName, () => 0);
				ingredients [ingredientName] += ingredientAmount;
			}
		}
		return [
			for (final MapEntry<String, num> entry in ingredients.entries)
				Item(entry.key, entry.value)
		];
	}

	static List<Item> filterItems(List<Item> items, {bool imports = true}) => [
		for (final Item item in items)
			if (Constants.productionCells.contains(item.name) == imports)
				item
	];

	static void printItemRequirements(List<Item> items) {
		for (final Item item in items) {
			if (Constants.rawResources.contains(item.name)) {
				// ignore: avoid_print
				print("You need $item per second");
			} else {
				final int numFactories = ItemAnalysis.getFactoryCount(item);
				// ignore: avoid_print
				print("You need $numFactories factories to produce $item.");			
			}
		}
	}
}
