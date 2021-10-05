import "dart:math";

import "furnace.dart";
import "position.dart";

class State {
	static const Position ironPatchPosition = Position(0, 0);
	static const Position coalPatchPosition = Position(0, 0);
	static final Random _random = Random();

	static Map<String, int> generateRandomInventory() => {
		"iron-ore": _random.nextInt(10),
		"iron-plate":  _random.nextInt(10),
		"ammo": _random.nextInt(20),
	};

	final Position position;
	final Map<String, int> inventory;
	final Furnace furnace;
	final int bitersInRadius;

	const State({
		required this.position,
		required this.inventory,
		required this.furnace,
		required this.bitersInRadius,
	});

	State.random() : 
		position = Position.random(),
		inventory = generateRandomInventory(),
		furnace = Furnace.random(),
		bitersInRadius = _random.nextInt(3);

	bool get isNearFurnace => position.isNear(Furnace.position);
	bool get isNearIron => position.isNear(ironPatchPosition);
	bool get isNearCoal => position.isNear(coalPatchPosition);

	int get ironPlates => inventory ["iron-plate"] ?? 0;
	int get ironOre => inventory ["iron-ore"] ?? 0;
	int get ammo => inventory ["ammo"] ?? 0;
}
