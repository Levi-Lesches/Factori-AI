// ignore_for_file: avoid_print

import "package:factorio/factory_generator/constants.dart";

import "positions.dart";
import "train.dart";

/// Groups multiple trains at the same vertex on the map.
/// 
/// This is used to simplify printing. On the map, one symbol is printed, and 
/// then underneath the map can be a legend, which lists all the collisions and 
/// which trains were involved. 
class Collision {
	/// The symbol for the collision.
	/// 
	/// This should be unique for all collisions.
	static String getSymbol() => "*";

	/// The symbol used to represent this collision on the map.
	final String symbol;

	/// The trains parked at this intersection. 
	final Map<int, Direction> trains;

	/// Groups multiple trains at the same vertex. 
	Collision(this.trains) : symbol = getSymbol();

	@override
	String toString() {
		final List<String> details = [
			for (final MapEntry<int, Direction> entry in trains.entries)
				"Train ${entry.key} facing ${entry.value}"
		];
		return "$symbol -- ${details.join(', ')}";
	}
}

/// A representation of the grid that facilitates fancy printing.
/// 
/// Technically, [grid] is not needed, since it is only looped over during 
/// [prettyPrint]. It can be removed to better integrate with [Position]s.
class Grid {
	/// Clears the screen.
	static void clearScreen() => print("\x1B[2J\x1B[0;0H");

	/// The amount of spaces to put between each column. 
	static const int columnSpacings = 18;

	/// The amount of spaces to put between each row.
	static const int rowSpacings = 2;

	/// Spacing between each row. 
	static String getRowSpacer() {
		final StringBuffer result = StringBuffer();
		for (int i = 0; i < rowSpacings; i++) {
			if (i > 0) {
				result.write("\n");
			}
			for (int j = 0; j < Constants.columns; j++) {
				result.write("|${' ' * columnSpacings}");
			}
		}
		return result.toString();
	}

	/// The string to insert between each row. 
	/// 
	/// This together with [columnSpacer] will form the cells of the grid. 
	static final String rowSpacer = getRowSpacer();

	/// The string to insert between each column. 
	/// 
	/// This together with [rowSpacer] will form the cells of the grid. 
	static final String columnSpacer = "-" * columnSpacings;


	/// The grid to represent. 
	final List<List<Vertex>> grid;

	/// The collisions on this map. 
	/// 
	/// These collisions should be enumerated in [prettyPrint], but will otherwise
	/// appear on the map as [Collision.symbol]. 
	final List<Collision> collisions = [];

	/// Creates a grid of vertices (train intersections).
	Grid() : grid = List.generate(
		Constants.rows, 
		(int row) => List.generate(
			Constants.columns, 
			(int column) => Vertex(row, column)
		)
	);

	/// The current states of all the trains on the grid. 
	/// 
	/// This is checked when printing the grid in order to properly display each
	/// train's position on the map.
	List<Train> currentFrame;

	/// Represents an individual vertex. 
	/// 
	/// By default, this returns a character that looks a part of a grid. However, 
	/// if there is a train on `vertex`, then the train index will be used instead.
	/// If there are multiple trains at the intersection, a new [Collision] will be
	/// added and recorded to [collisions], and [Collision.symbol] will be used.
	String printVertex(Vertex vertex) {
		final List<int> trains = [
			for (final MapEntry<int, Train> entry in currentFrame.asMap().entries)
				if (entry.value?.startingLocation == vertex)
					entry.key
		];
		return trains.isEmpty ? "+" : trains.length == 1 
			? trains.first.toString() : collision(trains);
	}

	/// Records and represents a new [Collision]. 
	String collision(List<int> indices) {
		final Map<int, Direction> trains = {
			for (final int index in indices)
				index: currentFrame [index].startingDirection
		};
		final Collision collision = Collision(trains);
		collisions.add(collision);
		return collision.symbol;
	}

	/// Prints the map along with the positions of all the trains in the `frame`.
	void prettyPrint(List<Train> frame) {
		currentFrame = frame;
		clearScreen();
		collisions.clear();
		for (final MapEntry<int, List<Vertex>> entry in grid.asMap().entries) {
			final int rowIndex = entry.key;
			final List<Vertex> row = entry.value;
			print(row.map(printVertex).join(columnSpacer));
			if (rowIndex != grid.length - 1) {
				print(rowSpacer);
			}
		}
		collisions.forEach(print);
	}
}
