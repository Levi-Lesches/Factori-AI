import "dart:math";

import "position.dart";

class Furnace {
	static const Position position = Position(0, 0);
	static final Random _random = Random();

	final int ore;
	final int plates;

	const Furnace({
		this.ore = 0,
		this.plates = 0,
	});

	Furnace.random() : 
		ore = _random.nextInt(10),
		plates = _random.nextInt(10); 

	Furnace copyWith({
		int? ore,
		int? plates,
	}) => Furnace(
		ore: ore ?? this.ore,
		plates: plates ?? this.plates,
	);

	bool get isWorking => ore > 0;
	bool get isReady => plates > 0;

	Furnace insertOre() => copyWith(ore: ore + 1);
	Furnace removePlates() => copyWith(plates: 0);

	Furnace simulate(Duration time) {		
		final int oresProcessed = (time.inSeconds ~/ 3.2).clamp(0, ore);
		return Furnace(
			ore: ore - oresProcessed,
			plates: plates + oresProcessed,
		);
	}
}
