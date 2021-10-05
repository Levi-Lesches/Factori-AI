import "package:factorio/calculator/constants.dart";

import "errors.dart";
import "item.dart";
import "node.dart";
import "recipe.dart";

extension CombiningMap on Map<String, num> {
	void addItem(Item item) {
		final String key = item.name;
		final num value = item.amount;
		putIfAbsent(key, () => value);
		this [key] += value;
	}
}

class ItemNode extends Node<Item> {
	factory ItemNode(Item item) {
		if (Constants.rawResources.contains(item.name)) 
			return ItemNode._(item, const []);
		final Recipe recipe = ParsedConstants.recipes [item.name];
		if (recipe == null) 
			throw NoRecipeError(item.name);
		final List<ItemNode> children = [];
		for (final Item ingredient in recipe.ingredients) {
			final double amount = 
				ingredient.amount / recipe.product.amount * item.amount;
			final Item adjustedItem = Item(ingredient.name, amount);
			final ItemNode node = ItemNode(adjustedItem);
			children.add(node);
		}
		return ItemNode._(item, children);
	}

	const ItemNode._(Item item, List<ItemNode> children) : 
		super(item, children);

	Map<String, num> collapse() {
		print("Collapsing ${value}");
		final Map<String, num> result = {value.name: value.amount};
		for (final ItemNode child in children) {
			final Item childItem = child.value;
			result.addItem(childItem);
			final Map<String, num> subtree = 
				Constants.productionCells.contains(childItem.name) 
					? {childItem.name: childItem.amount} : child.collapse();
			for (final MapEntry<String, num> entry in subtree.entries) {
				num amount = entry.value;
				// if (Constants.productivity.contains(value.name))
				// 	amount /= 1.4;
				result.addItem(Item(entry.key, amount));
			}
		}
		return result;
		// if (Constants.productionCells.contains(value.name))
		// 	return {value.name: value.amount};
		// final Map<String, num> result = {};
		// for (final ItemNode child in children) {
		// 	final Map<String, num> subresult = child.collapse();
		// 	for (final MapEntry<String, num> entry in subresult.entries) {
		// 		final String itemName = entry.key;
		// 		num amount = entry.value;
		// 		if (Constants.productivity.contains(value.name))
		// 			amount /= 1.4;
		// 		result.update(
		// 			itemName, 
		// 			(otherAmount) => amount + otherAmount,
		// 			ifAbsent: () => amount
		// 		);
		// 	}
		// }
		// return result;
	}
}
