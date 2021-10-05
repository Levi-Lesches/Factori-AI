import "package:factorio/factory_generator/models.dart";

import "positions.dart";

/// A train that can use A* to navigate to a destination.
/// 
/// Train stations are 1-way, meaning the direction the train enters the station
/// is important. For a state to be the solution state, [startingDirection] 
/// needs to match [targetDirection].
/// 
/// Use [getRoute] to automatically create trains for a list of vertices.
class Train extends AStarState {
	/// Finds the distance covered by a train going on a route.
	/// 
	/// Also includes the distance traveled going from the station to the first
	/// stop, as well as going from the last stop back to the station.
	static List<Train> getRoute(Position station, List<Vertex> route) {
		final List<AStarNode> nodes = [];
		// Start from the station
		final Vertex homeStation = station.dropoffStop;
		Vertex currentLocation = homeStation;
		Direction currentDirection = Direction.right;
		for (final Vertex destination in route) {
			final Train train = Train(
				startingLocation: currentLocation,
				startingDirection: currentDirection,
				targetLocation: destination,
				targetDirection: Direction.left,
			);
			nodes.add(train.aStar());

			// Reset for the next loop
			currentLocation = destination;
			currentDirection = Direction.left;
		}
		// Go back to the station
		final Train train = Train(
			startingLocation: currentLocation,
			startingDirection: currentDirection,
			targetLocation: homeStation,
			targetDirection: Direction.right,
		);
		nodes.add(train.aStar());

		return [
			Train(
				startingLocation: homeStation, 
				startingDirection: Direction.right, 
				targetLocation: route [0],
				targetDirection: Direction.left,
			),
			for (final AStarNode node in nodes) 
				...node.reconstruct()
		];
	}

	/// The vertex this train starts at.
	final Vertex startingLocation;

	/// The vertex this train needs to be at.
	final Vertex targetLocation;

	/// The direction this train starts in.
	final Direction startingDirection;

	/// The direction this train needs to be in.
	final Direction targetDirection;

	/// Creates a train.
	Train({
		required this.startingLocation,
		required this.targetLocation,
		required this.startingDirection,
		required this.targetDirection,
		depth = 0,
	}) : super(depth);

	@override
	List<Train> expand() => [
		for (final Direction direction in Direction.values)
			if (
				direction != oppositeDirections [startingDirection] &&  // can't go back
				startingLocation.isValidDirection(direction)  // stay inside the grid
			) Train(
				startingLocation: startingLocation.move(direction),
				startingDirection: direction,
				targetLocation: targetLocation,
				targetDirection: targetDirection,
				depth: depth + 1,  // NOT depth++
			)
	];

	@override
	String get hash => 
		"${directionNames [startingDirection]}"
		"$startingLocation-$targetLocation"
		"${directionNames [targetDirection]}";

	@override
	bool isSolution;

	@override
	String toString() => 
		"Train ($startingLocation --> $targetLocation, "
		"${directionNames [startingDirection]})";

	@override 
	int heuristic() {
		final int manhattanDistance = 
			startingLocation.getManhattanDistance(targetLocation);
		final int directionPenalty = startingDirection == targetDirection ? 0 : 1;
		isSolution = manhattanDistance == 0 && directionPenalty == 0;
		return depth + manhattanDistance + directionPenalty;
	}

	/// Returns the distance this train has to travel.
	/// 
	/// Uses the A* algorithm to find the optimal path, so takes non-trivial time.
	int getDistance({bool verbose = false}) => aStar(verbose: verbose).state.depth;
}
