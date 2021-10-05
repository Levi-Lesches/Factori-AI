import "package:meta/meta.dart";

import "item.dart";

@immutable
class Recipe {
	final String name;
	final Item product;
	final List<Item> ingredients;
	final num time;

	const Recipe({
		@required this.name,
		@required this.product, 
		@required this.ingredients,
		@required this.time,
	});

	Recipe.fromJson(Map json) :
		name = json ["name"],
		time = json ["time"],
		product = Item.fromJson(json ["product"]),
		ingredients = [
			for (final itemJson in json ["ingredients"])
				Item.fromJson(itemJson)
		];

	@override
	String toString() {
		final String ingredientsAsString = 
			ingredients.map((obj) => obj.toString()).join(", ");

		return '${product.toString()} "$name" ($ingredientsAsString)';
	}

	Map get json => {
		"product": product.json,
		"name": name,
		"time": time,
		"ingredients": [
			for (final Item ingredient in ingredients)
				ingredient.json
		],
	};
}

@immutable
class RecipeChain {
	final Recipe root;
	final List<Recipe> children;

	const RecipeChain(this.root, this.children);
}
