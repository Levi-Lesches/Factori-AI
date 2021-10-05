import "package:factorio/factory_generator/data.dart";

/// A collection of constants. 
/// 
/// This class is only for values set by me. For values read from the notes 
/// file, see [ParsedConstants].
class Constants {
	/// The rows in the grid.
	static const int rows = 5;

	/// The columns in the grid.
	static const int columns = 10;

	/// The total cells in the grid.
	static const int totalCells = rows * columns;

	/// All the cells that cannot be moved around. 
	/// 
	/// The algorithm should only deal with the [ParsedConstants.movableCells].
	static const Map<String, List<Position>> fixedPositions = {
		"brick + concrete": [Position(0, 6)], 
		"Iron ore 1": [Position(0, 7)],  // any name is valid
		"Iron ore 2": [Position(0, 9)],
		"Iron ore 3": [Position(1, 5)],
		"Copper ore 1": [Position(1, 2)],	
		"copper": [Position(1, 0), Position(1, 1)],
		"iron": [Position(1, 3), Position(1, 4)],
		"steel": [Position(1, 6), Position(1, 7)],
		"nuclear": [Position(1, 9)],
		"coal liquefaction": [Position(3, 6)],
	};

	/// Names in the notes file that don't exactly match their exports.
	static const Map<String, List<String>> aliases = {
		"oil processing": ["rocket fuel", "sulfur", "sulfuric acid", "lube"],
		"coal liquefaction": ["coal", "plastic"],
		"brick + concrete": ["brick", "concrete"],
		"solar farm": ["solar panel", "accumulator"],
		"infrastructure": ["rails", "cliff explosives", "landfill"],
	};

	/// Imports that can be worked in regardless of factory layout.
	static const Set<String> excludedImports = {
		"water", "crude oil", "stone", "iron ore", "copper ore", "coal"
	};
}

/// A collection of constants read from the notes file.
/// 
/// This class is only for values set in the notes file. For values chosen by 
/// me, see [Constants].
class ParsedConstants {
	/// The different sub-factories in the grid.
	static List<String> cells;

	/// The indices of values in [cells] that can move.
	/// 
	/// ie, are not in [Constants.fixedPositions].
	static List<int> movableCells;

	/// The number of empty cells needed to reach ([Constants.totalCells]).
	static int emptyCells;

	/// Each cell's priority. 
	/// 
	/// The algorithm should prefer shorter travel distances for cells with 
	/// higher priorities
	static Map<String, int> priorities;

	/// Maps cells to a list of their import stations.
	static Map<String, Set<String>> trainStops;

	/// Fills in [movableCells] and [emptyCells].
	static void calculateCellCounts() {
		movableCells = [
			for(final MapEntry<int, String> entry in cells.asMap().entries) 
				if (!Constants.fixedPositions.containsKey(entry.value))
					entry.key
		];
		final int fixedCells = Constants.fixedPositions.values.fold(
			0, (int a, List b) => a + b.length
		);
		final int occupiedCells = movableCells.length + fixedCells;
		emptyCells = Constants.totalCells - occupiedCells;
	}
}
