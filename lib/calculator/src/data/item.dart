import "package:meta/meta.dart";

@immutable
class Item {
	final String name;
	final num amount;
	const Item(this.name, this.amount);

	Item.fromJson(Map json) : 
		name = json ["name"],
		amount = json ["amount"];

	@override
	String toString() => 
		"$name${amount > 1 ? ' x${amount.toStringAsPrecision(2)}' : ''}";

	Map get json => {
		"name": name,
		"amount": amount,
	};
}
