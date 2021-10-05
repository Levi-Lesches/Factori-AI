/// Two grids are needed for this program: the factory grid, comprised of cells 
/// that produce exports and take in imports, and the rail network, where trains
/// move from station to station. 
/// 
/// Instead of creating two separate grids, and handling the complications that 
/// come with that, we use our grid for two purposes. The squares inside the
/// grid, where the sub-factories will be located, are represented by 
/// [Position] objects. The corners of each cell are represented by [Vertex]. 
/// Since each cell has 4 vertices (one in each corner), an m x n grid will have
/// (m + 1) x (n + 1) vertices.
/// 
/// In both cases, (0, 0) is the upper left corner. 
library grid;

/// A direction used to move through the rail network [Vertex].
enum Direction {
	/// Left.
	left,

	/// Right.
	right, 

	/// Up.
	up, 

	/// Down.
	down
}

/// A map where the values are opposite their keys.
/// 
/// This can be used to check if a turn would cause a U-turn. This can be used
/// with [Vertex.isValidDirection] to check if a train can make a turn.
const Map<Direction, Direction> oppositeDirections = {
	Direction.left: Direction.right,
	Direction.right: Direction.left,
	Direction.up: Direction.down,
	Direction.down: Direction.up,
};

/// String representations of the directions.
const Map<Direction, String> directionNames = {
	Direction.left: "left",
	Direction.right: "right",
	Direction.up: "up",
	Direction.down: "down",
};

/// A position in the factory grid.
/// 
/// See the library documentation for details about the grid.
class Position {
	/// The row this cell is located at.
	final int row;

	/// The column this cell is located at.
	final int col;

	/// Creates a position.
	const Position(this.row, this.col);

	@override 
	String toString() => "Position ($row, $col)";

	@override 
	int get hashCode => "$row, $col".hashCode;

	@override
	bool operator == (dynamic other) => other is Position &&
		row == other.row && col == other.col;

	/// Gets the pickup stop for this cell (upper right corner).
	Vertex get pickupStop => Vertex(row + 1, col);

	/// Gets the drop-off stop for this cell (lower left corner).
	Vertex get dropoffStop => Vertex(row, col + 1);
}

/// A vertex on a grid representing the train network.
/// 
/// See the library documentation for details about the grid.
class Vertex implements Comparable<Vertex> {
	/// Sort from left to right, so decreasing column order
	/// This is needed to let the trains enter the pickup stations from the right.
	@override
	int compareTo(Vertex other) => col.compareTo(other.col) * -1;

	/// The number of rows in the grid.
	/// 
	/// This is supposed to be taken from the `Constants` class. However, since 
	/// that class uses this library, to prevent a circular dependency this value
	/// must be manually set. 
	static int rows;

	/// The number of columns in the grid.
	/// 
	/// This is supposed to be taken from the `Constants` class. However, since 
	/// that class uses this library, to prevent a circular dependency this value
	/// must be manually set. 
	static int columns;

	/// The row of this vertex.
	final int row;

	/// The column of this vertex.
	final int col;

	/// Creates a vertex.
	const Vertex(this.row, this.col);

	@override
	bool operator == (Object other) => other is Vertex && 
		row == other.row && col == other.col;

	@override
	int get hashCode => toString().hashCode;

	@override
	String toString() => "Vertex ($row, $col)";

	/// Checks if a move in a given direction reaches outside the grid.
	/// 
	/// Does not check for U-turns. Use [oppositeDirections] for that.
	bool isValidDirection(Direction direction) {
		if (rows == null || columns == null) {
			throw StateError("Rows and columns have not been set");
		}
		switch (direction) {
			case Direction.left: return col > 0;
			case Direction.right: return col <= columns;
			case Direction.up: return row > 0;
			case Direction.down: return row <= rows;
			default: throw ArgumentError.value(direction, "direction");
		}
	}

	/// Returns a vertex by moving from the current vertex in [direction].
	Vertex move(Direction direction) {
		switch (direction) {
			case Direction.left: return Vertex(row, col - 1);
			case Direction.right: return Vertex(row, col + 1);
			case Direction.up: return Vertex(row - 1, col);
			case Direction.down: return Vertex(row + 1, col);			
			default: throw ArgumentError.value(direction, "direction");
		}
	}

	/// Returns the Manhattan distance between two vertices.
	/// 
	/// Manhattan distance is the horizontal distance plus the vertical distance.
	int getManhattanDistance(Vertex other) => 
		(row - other.row).abs() + (col - other.col).abs();
}

/// A point in an intersection where two tracks intersect.
/// 
/// As long as we're simulating train routes, we might find it helpful to stress
/// test the intersections as well to test for congestion. My factory uses a 
/// 2-way intersection, which allows for some trains to cross simultaneously, 
/// depending on direction. 
/// 
/// After studying the intersection, I found that the tracks within cross at 
/// certain locations, which can be used to programmatically test whether two 
/// trains can cross at the same time. I split the intersections into a 5x5 
/// grid, and if two trains share the same intersection (coordinates), then
/// they will need to wait for each other. Additionally trains that end up
/// wanting to go in the same direction will always have to wait.
class IntersectionPoint {
	/// The row for this intersection point.
	final int row;

	/// The column for this intersection point.
	final int col;

	/// Creates a point in an intersections where two tracks intersect.
	const IntersectionPoint(this.row, this.col);
}

/// Maps direction changes to intersection points. 
/// 
/// To test whether two trains can cross at the same time, check if they
/// share an intersection point. To use this map, pass the current direction
/// as the first key, and the target direction as the second. U-Turns are not
/// supported by the intersection, hence are not represented here. If a 
/// direction is not listed here, then it will always be safe to cross.
const Map<Direction, Map<Direction, Set<IntersectionPoint>>> intersections = {
	Direction.left: {
		Direction.left: {IntersectionPoint(2, 2), IntersectionPoint(2, 4)},
		Direction.down: {IntersectionPoint(3, 5), IntersectionPoint(5, 3)},
	},
	Direction.right: {
		Direction.up: {IntersectionPoint(3, 3), IntersectionPoint(1, 3)},
		Direction.right: {IntersectionPoint(4, 2), IntersectionPoint(4, 4)},
	},
	Direction.up: {
		Direction.up: {IntersectionPoint(4, 4), IntersectionPoint(2, 4)},
		Direction.left: {IntersectionPoint(5, 3), IntersectionPoint(3, 1)},
	},
	Direction.down: {
		Direction.down: {IntersectionPoint(2, 2), IntersectionPoint(4, 2)},
		Direction.left: {IntersectionPoint(1, 3), IntersectionPoint(3, 5)},
	}
};


/// A model of the intersection used throughout the rail network. 
/// 
/// As long as we're simulating train routes, we might find it helpful to stress
/// test the intersections as well to test for congestion. My factory uses a 
/// 2-way intersection, which allows for some trains to cross simultaneously, 
/// depending on direction. Ignoring the sometimes-safe crossing can 
/// artificially devalue a factory's efficiency. 
/// 
/// After studying the intersection, I found that the tracks within cross at 
/// certain locations, which can be used to programmatically test whether two 
/// trains can cross at the same time. I split the intersection into a 5x5 
/// grid, and if two trains share the same coordinates, then they will have to 
/// wait for each other.
/// 
/// Use [canPassSafely] to determine if two trains can cross safely. 
class Intersection {
	/// A map of the intersecting paths on this intersection. 
	/// 
	/// By drawing the paths of the intersection, we can analyze how it works.
	/// First, draw the straight paths. Then, draw the paths for all the left 
	/// turns, noting that all right turns can always be made safely. 
	/// 
	/// You should end up with two drawings: a tic-tac-toe style grid of straight 
	/// paths, and the left turns in a diamond shape. By superimposing the two, 
	/// you get a square of rails. Split the square into a 5x5 grid. For every 
	/// cell where two paths intersect, fill in an "X", and a check for every 
	/// clear cell. You should end up with "X"s at the following coordinates: 
	/// 	
	/// 	0. (1, 3)
	/// 	1. (2, 2)
	/// 	2. (2, 4)
	/// 	3. (3, 1)
	/// 	4. (3, 5)
	/// 	5. (4, 2)
	/// 	6. (4, 4)
	/// 	7. (5, 3)
	/// 
	/// The numbers below correspond to these coordinates. Any two trains whose
	/// paths share these coordinates will need to wait for each other. The first
	/// key of this map is the starting direction of the train, and the second is 
	/// the final (target) direction. Note that since U-turns are not allowed, 
	/// opposite directions are not present, as well as right turns, since they 
	/// are always safe (ie, they don't have an "X" in their graph). 
	/// 
	/// Do not use this map directly. Instead, use [canPassSafely]. 
	static const Map<Direction, Map<Direction, Set<int>>> intersections = {
		Direction.left: {
			Direction.left: {1, 2},
			Direction.down: {4, 7}
		}, 
		Direction.right: {
			Direction.right: {5, 6},
			Direction.up: {0, 3}
		},
		Direction.up: {
			Direction.up: {2, 6},
			Direction.left: {3, 7},
		},
		Direction.down: {
			Direction.down: {1, 5},
			Direction.right: {0, 4}
		},
	};	

	/// Whether two trains can pass through the intersection simultaneously.
	/// 
	/// This function works by checking [intersections] to see which points each 
	/// train crosses and returning true iff they do not share any points.  
	static bool canPassSafely(
		Direction startingDirectionA, 
		Direction targetDirectionA, 
		Direction startingDirectionB,
		Direction targetDirectionB,
	) {
		// Must use null-aware here since safe directions are null in [intersections].
		final Set<int> intersectionA = 
			intersections [startingDirectionA] [targetDirectionA] ?? {};
		final Set<int> intersectionB = 
			intersections [startingDirectionB] [targetDirectionB] ?? {};
		final Set<int> conflicts = intersectionA.intersection(intersectionB);
		return conflicts.isEmpty;
	}
}
