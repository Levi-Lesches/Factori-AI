// The A* algorithm supports logging.
// ignore_for_file: avoid_print
import "package:factorio/utils.dart";

/// A state used for the A* algorithm.
/// 
/// To use, create a subclass with the following: 
/// 
/// - A [hash] getter to compactly represent the state as a string.
/// - An [expand] method to create other states.
/// - A [heuristic] method to evaluate the state.
/// - A constructor that passes [depth] to `super`. 
/// 
/// An A* algorithm can then access [depth], [cost], [hash], and [expand]. Note
/// that this class implements [Comparable], so lists will be automatically
/// sorted by [cost].
abstract class AStarState implements Comparable<AStarState> {
	@override
	int compareTo(AStarState other) => cost.compareTo(other.cost);

	/// The cost of this state.
	/// 
	/// See [heuristic] for how to implement this value. The result is cached here.
	int cost;

	/// The amount of expansions it took to reach this state. 
	/// 
	/// When relevant, this helps the algorithm to prefer equivalent states that
	/// require the least amount of expansions. To do this, make sure to include
	/// it in [heuristic].
	final int depth;

	/// Creates a state.
	/// 
	/// If the amount of "moves" matters, make sure to increment [depth] every 
	/// time [expand] is used.
	AStarState([this.depth = 0]) {
		cost = heuristic();
	}

	/// Whether this state is the solution.
	/// 
	/// Since [heuristic] takes [depth] into account, perfect solutions can have 
	/// [cost] greater than 0. This value should be used instead to identify the 
	/// solution state.
	bool get isSolution;

	/// Generates other states from this state. 
	/// 
	/// The key to using an A* algorithm is ensuring this function really produces
	/// all possible states that can be reached from the current state.
	/// 
	/// Additionally, if the amount of "moves" matters, make sure to increment 
	/// [depth] when creating the new states.
	List<AStarState> expand();

	/// A unique hash for efficiently comparing two states.
	/// 
	/// A new field was created instead of overriding [hashCode] since it cannot
	/// be enforced.
	String get hash;

	/// A relative cost for this state.
	/// 
	/// The key to using an A* algorithm is ensuring this function accurately 
	/// detects and represents any changes that change how close this state is
	/// to the solution state. A higher value indicates a less ideal state.
	/// 
	/// Additionally, when the amount of expansions matters, make sure to take
	/// [depth] into account when overriding this function.
	int heuristic();

	/// The A* algorithm.
	/// 
	/// Subclass [AStarState] to describe the problem and this algorithm will find 
	/// a solution. 
	/// 
	/// This function has 4 main parts: 
	/// 
	/// 1. Pop a node ([AStarNode]) from the queue and expand it.
	/// 2. Evaluate each child
	/// 3. Cache the node and repeat
	AStarNode aStar({
		bool verbose = false,
		int logIntervals = 10,
	}) {
		final Set<String> explored = {};
		// The smallest element of the queue will be popped
		// If it's sorted in decreasing order, this element will always be the last
		// That way, the time complexity of .pop will be O(1) and not O(n).
		// See https://api.dart.dev/stable/2.7.2/dart-core/List/removeAt.html
		// 
		// Also, by keeping the elements sorted, the least costly state will always 
		// be known, which helps with code simplicity.
		final List<AStarNode> queue = [AStarNode(this, null)];  
		int counter = 0;

		while (queue.isNotEmpty) {
			// Step 1. Choose a new node and expand it.
			final AStarNode node = queue.removeLast();
			for (final AStarNode node in node.expand()) {
				if (verbose && ++counter % logIntervals == 0) {
					print(
						"Possibility #${counter.toString().padRight(4)}"
						"  Queue: ${queue.length.toString().padRight(4)}"
						"  Explored: ${explored.length.toString().padRight(3)}"
						"  Depth: ${node.state.depth.toString().padRight(3)}"
						"  Current cost: ${node.state.cost}"
						"  Sample: ${node.state}"
					);
				}
				// Step 2. Evaluate each child.
				if (node.state.isSolution) {
					return node;
				} else if (explored.contains(node.state.hash)) {
					continue;  // already expanded an equivalent state
				} else {
					sortedInsert<AStarNode>(
						queue, node, (AStarNode node) => node.state.cost, increasing: false
					);
				}
			}
			// Step 3. Cache and repeat.
			explored.add(node.state.hash);  // fully expanded
		}
		return null;  // no solution 
	}
}

/// A node for the A* algorithm.
/// 
/// Instead of simply keeping [AStarState] objects, the algorithm retains both 
/// each state as well as pointers to their parents (and so on). This class 
/// bundles a state to both its parent and a pointer to its grandparent. By 
/// recursively examining a node, one can reconstruct the order taken by the
/// algorithm.
class AStarNode {
	/// The current state.
	final AStarState state;

	/// This node's parent node.
	/// 
	/// By backtracking every node's parent, one can completely reconstruct the 
	/// path taken by the algorithm.
	final AStarNode parent;

	/// Creates a node for the A* algorithm.
	const AStarNode(this.state, this.parent);

	/// Generates nodes for all of [state]'s possible expansions.
	/// 
	/// Importantly, sets the parent of the new nodes to `this` to preserve
	/// the path taken by the algorithm.
	List<AStarNode> expand() => [
		for (AStarState change in state.expand())
			AStarNode(change, this)
	];

	Iterable<AStarState> reconstruct({bool reverse = true}) {
		final List<AStarState> result = [];
		AStarNode node = this;
		while(node.parent != null) {
			result.add(node.state);
			node = node.parent;
		}
		// result.add(node.state);
		return reverse ? result.reversed : result;
	}
}
