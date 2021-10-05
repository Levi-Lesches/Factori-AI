import "package:factorio/factory_generator/constants.dart";
import "package:factorio/factory_generator/models.dart";

import "positions.dart";

/// A representation of the factory as a whole.
/// 
/// The factory is a grid of individual cells that each have their own
/// imports and exports. Some cells are fixed ([Constants.fixedPositions]), 
/// either because they use resources on the map or because I built it that way,
/// so this class's [hash] only represents the movable cells 
/// ([ParsedConstants.movableCells]).
/// 
/// Annoyingly, the fixed position cells don't allow us to calculate position 
/// in 2D grid ([layout]) from a 1D list ([hash]). The [getLayout] function 
/// builds the grid before any work is done and the result is saved to [layout]
/// to be used by [toString] and [evaluate].
class Factory extends GeneticAlgorithmState<int> {
	/// Generates a 2D layout from a hash.
	static List<List<String>> getLayout(List<int> hash) {
		int index = 0;
		final List<List<String>> result = [];
		for (int row = 0; row < Constants.rows; row++) {
			final List<String> rowList = [];
			for (int col = 0; col < Constants.columns; col++) {
				bool skip = false;
				for (
					final MapEntry<String, List<Position>> entry in 
					Constants.fixedPositions.entries
				) {
					if (entry.value.contains(Position(row, col))) {
						skip = true;
						rowList.add(entry.key);
						break;
					}
				}

				if (skip) {
					continue;
				}

				final int cellIndex = hash [index++];
				rowList.add(cellIndex == null ? null : ParsedConstants.cells [cellIndex]);
			}
			result.add(rowList);
		}
		return result;
	}

	/// Converts a 2D grid to a hash.
	/// 
	/// This should not be used by the algorithm, since it is unnecessarily time 
	/// consuming. Instead, create new hashes and use [getLayout] if you need a 
	/// grid. This function was only intended for debug purposes.
	static List<int> getHash(List<List<String>> layout) {
		final List<int> result = [];
		for (final List<String> row in layout) {
			for (final String cell in row) {
				if (cell == null) {
					result.add(null);
				} else if (!Constants.fixedPositions.containsKey(cell)) {  // can't move
					if (cell == "depot" && !ParsedConstants.cells.contains("depot")) {
						ParsedConstants.cells.add("depot");
					}
					final int cellIndex = ParsedConstants.cells.indexOf(cell);
					if (cellIndex == -1) {
						throw ArgumentError.value(cell, "Cell of layout", "Cannot find cell");
					}
					result.add(cellIndex);
				}
			}
		}
		return result;
	}

	/// A 2D grid of the factory.
	/// 
	/// Needed for printing as a string and locating individual cells in the grid.
	final List<List<String>> layout;

	/// Creates a factory from a hash.
	Factory(List<int> hash) : 
		assert(
			hash.length == 
				ParsedConstants.movableCells.length + ParsedConstants.emptyCells,
			"Invalid hash with length ${hash.length}: $hash"
		),
		layout = getLayout(hash),
		super(hash);

	/// Creates a random factory.
	factory Factory.random() => Factory(
		ParsedConstants.movableCells + 
		List.filled(ParsedConstants.emptyCells, null)
		..shuffle()
	);

	@override
	Factory fromHash(List<int> hash) => Factory(hash);

	@override 
	String toString() {
		final StringBuffer buffer = StringBuffer();
		for (final List<String> row in layout) {
			for (final String cell in row) {
				buffer.write("${cell == null ? " " * 20 : cell.padRight(20)}| ");
			}
			buffer
				..write("\n")
				..write(("${'-' * 20}+-") * Constants.columns)
				..write("\n");
		}
		return buffer.toString();
	}

	/// Gets the position of a cell in [layout].
	/// 
	/// This loops over [layout] instead of doing index math since [hash] doesn't 
	/// account for the cells in [Constants.fixedPositions].
	Position getPosition(String cell) {
		for (int row = 0; row < Constants.rows; row++) {
			for (int column = 0; column < Constants.columns; column++) {
				if (layout [row] [column] == cell) {
					return Position(row, column);
				}
			}
		}
		throw ArgumentError.value(cell, "station", "Cannot locate station");
	}

	@override
	int evaluate({bool verbose = false}) {
		final TrainsSimulator simulator = TrainsSimulator(this, verbose: verbose)
			..simulate();
		return simulator.score;
	}
}
