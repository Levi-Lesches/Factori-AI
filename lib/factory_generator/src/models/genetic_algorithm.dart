import "dart:math" show Random;
import "package:meta/meta.dart";
import "package:factorio/utils.dart";

// The genetic algorithm will need to print verbose logging. 
// Can be fixed by adding a Logger class... later.
// ignore_for_file: avoid_print

/// A state to be used in a genetic algorithm.
/// 
/// To use, create a subclass with the following: 
/// 
/// - A clear structure for how [hash] will represent the state.
/// - A "hash type" H to be used in the hash (`List<H> hash`).
/// - An [evaluate] function to determine a state's [fitness].
/// - A constructor that gives the super constructor [hash] and the evaluator.
/// - A [fromHash] method to call the sub-constructor with a hash.
/// 
/// A genetic algorithm can access [cross], [mutate], and [fitness]. The 
/// algorithm will also need to generate a random population, so it will need 
/// a way to produce random states. The simplest way to do this is with a 
/// `random` factory, but since constructors cannot be enforced, this is 
/// left up to the subclass implementation.
/// 
/// A minimal override of this class: 
/// ```dart
/// class State extends GeneticAlgorithmState<int> {
/// 
/// 	State(List<int> hash) : super(hash, evaluate);
/// 
/// 	@override
/// 	State fromHash(List<int> hash) => State(hash);
/// 
/// 	@override
/// 	int evaluate(List<int> hash) => null;  // fill this in
/// }
/// ```
/// 
/// Additional functions that can be overridden: 
/// 
/// - [compareTo]: compares to other states based on fitness.
/// - [crossHashes]: crosses two hashes to produce two "children" hashes.
/// - [mutation]: mutates the state with a chance of [mutationChance].
abstract class GeneticAlgorithmState<H>
	implements Comparable<GeneticAlgorithmState<H>> 
{
	static final Random _random = Random();

	/// Stores [hash] and [fitness]. 
	GeneticAlgorithmState(this.hash) {
		fitness = evaluate();
	}

	@override 
	int compareTo(GeneticAlgorithmState<H> other) => 
		fitness.compareTo(other.fitness);

	/// Crosses 2 hashes to produces 2 children (returned as lists).
	/// 
	/// Nulls are allowed. However they cause an issue since this function often
	/// checks to see if an element is already in the list, which `null` is. 
	/// Instead, the function counts how many nulls it assigns to each hash to
	/// keep them equal.
	/// 
	/// This function should not be called directly. Its return value is used by 
	/// [cross] to create new "children" states. Override this function to 
	/// override the default crossing behavior.
	/// 
	/// The key to using a genetic algorithm is ensuring this function creates 2 
	/// children states that both carry some inherent "traits" of their parents.
	///  
	/// This function has 4 steps: 
	/// 
	/// 1. Choose a1 at random
	/// 2. Infer a2
	/// 3. Choose b1 and b2 based on a1
	/// 4. return [a1 + b2, b1 + a2]
	List<List<H>> crossHashes (List<H> a, List<H> b) {
		assert(a.length == b.length, "Hashes need to be the same length to cross");

		final int halfLength = (a.length.isEven) ? a.length ~/ 2 : a.length ~/ 2 + 1;

		// Step 1. Choose a1 at random.
		final List<H> a1 = [];
		final Set<int> randomIndices = {};
		while (a1.length < halfLength) {
			final int index = _random.nextInt(a.length);
			if (!randomIndices.contains(index)) {
				randomIndices.add(index);
				a1.add(a [index]);
			}
		}
		final int a1Nulls = a1.where((H element) => element == null).length;
		final int aNulls = a.where((H element) => element == null).length;

		// Step 2. Choose a2 that don't conflict with a1
		int a2Nulls = 0;
		final List<H> a2 = [
			for (final H value in a)
				if (!a1.contains(value) || (value == null && a2Nulls++ < aNulls - a1Nulls)) 
					value
		];

		// Step 3. Choose b1 and b2 based on a1.
		int b2Nulls = 0;
		final List<H> b1 = [];
		final List<H> b2 = [];
		for (final H value in b) {
			if (a1.contains(value)) {
				if (value == null && b2Nulls++ < aNulls - a1Nulls) {
					b1.add(value);
				} else {
					b2.add(value);
				}
			} else {
				b1.add(value);
			}
		}

		final List<H> hash1 = a1 + b1;
		final List<H> hash2 = a2 + b2;

		assert(
			hash1.length == a.length, 
			"Invalid length for hash1: ${hash1.length}. Should be ${hash.length}: $hash1"
		);
		assert(
			hash2.length == a.length, 
			"Invalid length for hash2: ${hash2.length}. Should be ${hash.length}: $hash2"
		);
		
		// Step 4. Merge
		return [a1 + b1, a2 + b2];
	}

	/// Mutates the given state. 
	/// 
	/// This function should not be called directly. Instead, it is used with
	/// [mutationChance] in [mutate]. Override this function to modify the 
	/// default mutation behavior. Override [mutationChance] to modify the chance
	/// of mutation.
	/// 
	/// The key to using a genetic algorithm is ensuring this function only makes
	/// a minor change, which can sometimes be enough to shake up the algorithm to 
	/// produce more optimal results.
	/// 
	/// This function has 2 steps: 
	/// 
	/// 1. Choose two different indices. 
	/// 2. Swap the values of those indices in [hash].
	List<H> mutation() {
		final int index1 = _random.nextInt(hash.length);
		int index2;
		while (index2 != index1) {
			index2 = _random.nextInt(hash.length);
		}

		final List<H> hashCopy = List.from(hash);
		final H temp = hashCopy [index1];
		hashCopy [index1] = hashCopy [index2];
		hashCopy [index2] = temp;
		return hashCopy;
	}

	/// The chance that this state will mutate into another (similar) state.
	/// 
	/// The key to using a genetic algorithm is having this be low enough to not
	/// interfere with the structured natural selection, while also helping it 
	/// get out of sub-optimal states.
	double get mutationChance => 0.02;

	/// The hash this state can use to cross with other states.
	/// 
	/// The key to using a genetic algorithm is structuring the hash so that it 
	/// accurately represents the whole state.
	final List<H> hash; 

	/// The fitness value of this state. 
	/// 
	/// Do not override this value. Instead, override [evaluate].
	int fitness;

	/// Determines a state's fitness.
	/// 
	/// The key to using a genetic algorithm is ensuring this function returns 
	/// lower values if a state is more "ideal".
	int evaluate();

	/// Creates a new state from a hash. 
	/// 
	/// This is not a constructor because the abstract class needs access to the
	/// constructor of its subclasses. Each subclass should override this with 
	/// their own constructor. Additionally, this function does not restrict the 
	/// return value, meaning it is up to the subclass to be careful to return 
	/// another subclass of its type, and not any state with the same hash type. 
	GeneticAlgorithmState<H> fromHash(List<H> hash);

	/// Crosses this state with another one. 
	/// 
	/// Passes both state's [hash]es to [crossHashes] and returns new states. 
	/// Unfortunately, Dart does not support multiple return types, so for now this
	/// function returns a `List<S>` instead of `S, S`. Only the first two elements
	/// of this list should exist.
	/// 
	/// Do not override this directly. To override the default cross behavior, 
	/// override [crossHashes].
 	List<GeneticAlgorithmState<H>> cross(
 		covariant GeneticAlgorithmState<H> other
	) {
 		final List<List<H>> result = crossHashes(hash, other.hash);
 		return [for (final List<H> newHash in result) fromHash(newHash)];
	}

	/// Has a chance [mutationChance] of returning a mutated state. 
	/// 
	/// Most of the time, this function should return null. Otherwise, it returns 
	/// this state with a _small_ mutation, to give the genetic algorithm a 
	/// better chance of finding a better solution.
	/// 
	/// Do not override this directly.
	/// To override the mutation chance, override [mutationChance].
	/// To override the mutation function, override [mutation].
	GeneticAlgorithmState<H> mutate() =>
		_random.nextInt(100) < 100 * mutationChance
			? fromHash(mutation()) : null;
}

/// The default toString function.
/// 
/// This is used instead of [Object.toString] where a _function_ is needed.
String defaultToString(GeneticAlgorithmState state) => state.toString();

/// Runs a genetic algorithm. 
/// 
/// Subclass [GeneticAlgorithmState] to describe the problem as well as valid 
/// solutions, and let this function do the rest. 
/// 
/// Overall, this function has four main parts: 
/// 
/// 1. Generate a random population.
/// 2. Picks two of the top third of the population and crosses them.
/// 3. Mutates the children.
/// 4. Inserts the children into the population based on fitness.
GeneticAlgorithmState<H> geneticAlgorithm<H>({
	@required GeneticAlgorithmState<H> Function() generateRandomState,
	int populationSize = 50, 
	int generations = 5000,
	bool verbose = false,
	int verboseGenerations = 500,
	String Function(GeneticAlgorithmState<H> state) verboseFunction 
		= defaultToString,
}) {

	final Random random = Random();

	/// Chooses a random state from the most fit 1/3 of the population.
	GeneticAlgorithmState<H> chooseRandomState(
		List<GeneticAlgorithmState<H>> population
	) => population [
		random.nextInt(population.length ~/ 3)
	];

	// Step 1. Generate a random population.
	final List<GeneticAlgorithmState<H>> population = [
		for (int _ = 0; _ < populationSize; _++) 
			generateRandomState()
	]..sort();  // [GeneticAlgorithmState<H>] implements [Comparable].

	int currentGeneration = 0;
	int mutations = 0;
	while(currentGeneration < generations) {
		// Verbose logging
		if (verbose && currentGeneration % verboseGenerations == 0) {
			print("Genetic algorithm status report, generation $currentGeneration");
			for (int index = 0; index < 3; index++) {
				print("\t${index + 1}) Fitness: ${population [index].fitness}");
				print(verboseFunction(population [index]));
			}
		}

		// Body of the algorithm.
		for (int _ = 0; _ < populationSize ~/ 2; _++) {
			// Step 2. Pick two random states and cross them.
			/// Importantly, replaces the states with their children.
			GeneticAlgorithmState<H> state1 = chooseRandomState(population);
			GeneticAlgorithmState<H> state2 = chooseRandomState(population);
			List<GeneticAlgorithmState<H>> children;
			children = state1.cross(state2);
			state1 = children [0];
			state2 = children [1];

			// Step 3. Mutate the children.
			GeneticAlgorithmState<H> mutation = state1.mutate();
			if (mutation != null) {
				state1 = mutation;
				mutations++;
			}
			mutation = state2.mutate();
			if (mutation != null) {
				state2 = mutation;
				mutations++;
			}

			// Step 4. Insert back into the population.
			sortedInsert<GeneticAlgorithmState<H>>(
				population, state1, (state) => state.fitness
			);
			sortedInsert<GeneticAlgorithmState<H>>(
				population, state2, (state) => state.fitness
			);

			// Kill off two states to account for the new states.
			population
				..removeAt(population.length - 1)
				..removeAt(population.length - 1);
		}

		currentGeneration++;
		if (currentGeneration == generations) {
			break;
		}
	}

	final double mutationRate = mutations / (populationSize * generations) * 100;
	final String mutationString = mutationRate.toStringAsPrecision(2);
	print("Mutations: $mutations (mutation rate of $mutationString%");
	return population [0];
}
