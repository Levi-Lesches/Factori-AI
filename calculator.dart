// ignore_for_file: avoid_print

// import "package:factorio/calculator/constants.dart";
import "package:factorio/calculator/data.dart";
import "package:factorio/calculator/models.dart";
import "package:factorio/calculator/services.dart";

Future<void> main(List<String> args) async {
	await Services.instance.init();

	if ({"-c", "--clear-data"}.any(args.contains)) 
		await Services.instance.clearData();

	// final List<Item> ingredients = 
	// 	ItemAnalysis.mergeIngredients(Constants.scienceProducts);
	// print(ingredients);


	for (final String arg in {"-i", "--item"}) {
		int index = args.indexOf(arg);
		if (index == -1) continue;
		final String itemName = args [++index];
		final num itemCount = double.parse(args [++index]);
		final Item item = Item(itemName, itemCount);
		final ItemNode node = ItemNode(item);
		final Map<String, num> ingredients = node.collapse();
		print(ingredients);
	// 	final List<Item> ingredients = ItemAnalysis.getIngredients([item]);
	// 	final List<Item> imports = ItemAnalysis.filterItems(ingredients);
	// 	final List<Item> intermediates = 
	// 		ItemAnalysis.filterItems(ingredients, imports: false);
	// 	print("Imports: $imports");
	// 	print("Exports: $intermediates");
		return;
	}

	// ItemAnalysis.printItemRequirements(ingredients);
	// Services.instance.dispose();
}
