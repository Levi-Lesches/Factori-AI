import "package:factorio/factory_generator/data.dart";
import "package:factorio/factory_generator/constants.dart";

class TrainsSimulator {
	final Factory layout;  // factory is a reserved keyword
	final bool verbose;

	Map<String, List<Train>> frames;
	Map<String, Train> state;
	int score;

	TrainsSimulator(this.layout, {this.verbose = false}) {
		frames = getFrames();
		state = {
			for (MapEntry<String, List<Train>> entry in frames.entries)
				entry.key: entry.value.removeAt(0)
		};
	}

	void debugPrint(String message) {
		if (verbose) print(message);  // ignore: avoid_print
	}

	void prettyPrint() {
		if (!verbose) return;
		debugPrint("Current locations of trains: ");
		for (final MapEntry<String, Train> entry in state.entries) {
			final String name = entry.key;
			final Train train = entry.value;
			final Vertex location = train.startingLocation;
			final Direction direction = train.startingDirection;
			debugPrint("  $name: $location, facing $direction");
		}
	}

	Map<String, List<Train>> getFrames() {
		final Map<String, List<Train>> frames = {};
		for (final int cellIndex in layout.hash) {
			if (cellIndex == null) {  // empty cell
				continue;
			}
			final String cell = ParsedConstants.cells [cellIndex];
			final List<Vertex> route = [
				for (final String station in List.from(ParsedConstants.trainStops [cell]))
					layout.getPosition(station)?.pickupStop,
			]..remove(null)..sort();  // order from RIGHT TO LEFT.
			frames [cell] = Train.getRoute(layout.getPosition(cell), route);
		}
		return frames;
	}

	void moveTrain(String cell) {
		if (frames [cell].isEmpty) {
			state.remove(cell);
		} else {
			state [cell] = frames [cell].removeAt(0);
		}
		score += ParsedConstants.priorities [cell];
	}

	bool areConflicting(String cell1, String cell2) {
		final Train nextTrain1 = frames [cell1].first;
		final Train nextTrain2 = frames [cell2].first;
		final bool sameDestination = 
			nextTrain1.startingLocation == nextTrain2.startingLocation;
		final bool canPass = Intersection.canPassSafely(
			state [cell1].startingDirection,
			nextTrain1.startingDirection,
			state [cell2].startingDirection,
			nextTrain2.startingDirection,
		);
		return !canPass || sameDestination;
	}

	Iterable<String> getConflictingCells(String cell, List<String> queue) sync*{
		final Train train = state [cell];
		for (final String otherCell in queue) {
			if (
				cell != otherCell 
				&& train.startingLocation == state [otherCell].startingLocation
				&& frames [otherCell].isNotEmpty
			) yield otherCell;
		}
	}

	void handleConflict(Vertex location, List<String> cells) {
		final String cellToAllow = cells.first;
		debugPrint("Resolving the conflict at $location");
		debugPrint("  Trains waiting: $cells. Allowing $cellToAllow to pass");
		moveTrain(cellToAllow);
	}

	bool hasConflict(String cell, List<String> queue) => frames [cell].isEmpty 
		|| getConflictingCells(cell, queue).any(
			(String otherCell) => areConflicting(cell, otherCell)
		);

	void simulate() {
		score = 0;
		while (state.isNotEmpty) {
			prettyPrint();
			final Map<Vertex, List<String>> conflicts = {};
			final List<String> queue = state.keys.toList();
			final List<String> processed = [];  // cannot modify queue while looping

			for (final String cell in queue) {
				final Train train = state [cell];
				debugPrint("Moving $cell. Currently at ${train.startingLocation}");

				if (hasConflict(cell, queue)) {
					debugPrint("  This train cannot pass");
					conflicts.putIfAbsent(train.startingLocation, () => []);
					conflicts [train.startingLocation].add(cell);
				} else {
					debugPrint("  This train can pass safely");
					processed.add(cell);
				}
			}

			processed.forEach(moveTrain);
			conflicts.forEach(handleConflict);
		}
	}
}