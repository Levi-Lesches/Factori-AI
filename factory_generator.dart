// ignore_for_file: avoid_print

import "dart:io";
import "package:factorio/factory_generator/constants.dart";
import "package:factorio/factory_generator/data.dart";
import "package:factorio/factory_generator/models.dart";
import "package:factorio/factory_generator/parsers.dart";
import "package:factorio/utils.dart";

/*

 /$$$$$$$$                   /$$                         /$$                  /$$$$$$  /$$   /$$                     /$$$$$$$  /$$                     /$$
| $$_____/                  | $$                        |__/                 /$$__  $$|__/  | $$                    | $$__  $$| $$                    | $$
| $$    /$$$$$$   /$$$$$$$ /$$$$$$    /$$$$$$   /$$$$$$  /$$  /$$$$$$       | $$  \__/ /$$ /$$$$$$   /$$   /$$      | $$  \ $$| $$  /$$$$$$   /$$$$$$$| $$   /$$  /$$$$$$$
| $$$$$|____  $$ /$$_____/|_  $$_/   /$$__  $$ /$$__  $$| $$ /$$__  $$      | $$      | $$|_  $$_/  | $$  | $$      | $$$$$$$ | $$ /$$__  $$ /$$_____/| $$  /$$/ /$$_____/
| $$__/ /$$$$$$$| $$        | $$    | $$  \ $$| $$  \__/| $$| $$  \ $$      | $$      | $$  | $$    | $$  | $$      | $$__  $$| $$| $$  \ $$| $$      | $$$$$$/ |  $$$$$$
| $$   /$$__  $$| $$        | $$ /$$| $$  | $$| $$      | $$| $$  | $$      | $$    $$| $$  | $$ /$$| $$  | $$      | $$  \ $$| $$| $$  | $$| $$      | $$_  $$  \____  $$
| $$  |  $$$$$$$|  $$$$$$$  |  $$$$/|  $$$$$$/| $$      | $$|  $$$$$$/      |  $$$$$$/| $$  |  $$$$/|  $$$$$$$      | $$$$$$$/| $$|  $$$$$$/|  $$$$$$$| $$ \  $$ /$$$$$$$/
|__/   \_______/ \_______/   \___/   \______/ |__/      |__/ \______/        \______/ |__/   \___/   \____  $$      |_______/ |__/ \______/  \_______/|__/  \__/|_______/
                                                                                                     /$$  | $$
                                                                                                    |  $$$$$$/
                                                                                                     \______/
*/

List<int> getFitnessValues() {
	final int hashLengths = 
		ParsedConstants.movableCells.length + ParsedConstants.emptyCells;
	final List<List<String>> layout = [];
	final List<List<int>> hashes = [];
	final File file = File("results.txt");
	final List<String> lines = file.readAsStringSync().split("\n");
	for (final String line in lines) {
		if (line.trim().isEmpty) {
			if (layout.isEmpty) {
				continue;
			}
			final List<int> hash = Factory.getHash(layout);
			if (hash.length != hashLengths) {
				throw AssertionError(
					"Invalid length for hash: ${hash.length}. Should be $hashLengths"
				);
			}
			hashes.add(hash);
			layout.clear();
		} else if (!line.startsWith("-") && int.tryParse(line.trim() [0]) == null) {
			final List<String> row = [];
			for (String cell in line.split("|")..removeLast()) {
				cell = cell.trim();
				row.add(cell.isEmpty ? null : cell);
			}
			if (row.length != Constants.columns) {
				throw AssertionError("Invalid row length ${row.length} for row: $row");
			}
			layout.add(row);
		}
	}
	return [
		for (final List<int> entry in hashes)
			Factory(entry).fitness
	];
}

void debug() {}

String getArg(List<String> args, Set<String> aliases) {
	final int index = args.indexWhere(aliases.contains);
	return index == -1 ? null : args [index + 1];
}

void main(List<String> args) {
	final List<String> lines = NotesReader.relevantLines;
	final Map<String, int> cellsAndLines = NotesParser.getCellsAndLines(lines);
	ParsedConstants.cells = cellsAndLines.keys.toList();
	ParsedConstants.trainStops = NotesParser.getTrainRoutes(cellsAndLines, lines);
	ParsedConstants.calculateCellCounts();

	Vertex.rows = Constants.rows;
	Vertex.columns = Constants.columns;

	if ({"-h", "--help"}.any(args.contains)) {
		printHelp();
	} else if ({"-f", "--fitness", "-e", "--evaluate"}.any(args.contains)) {
		print(getFitnessValues());
	} else if ({"-r", "--run"}.any(args.contains)) {
		final int populationSize = 
			int.parse(getArg(args, {"-p", "--population"}) ?? "50");

		final int generations = 
			int.parse(getArg(args, {"-g", "--generations"}) ?? "50");

		final int logInterval = 
			int.parse(getArg(args, {"-l", "--log-interval"}) ?? "1");

		final Factory bestFactory = geneticAlgorithm<int>(
			generateRandomState: () => Factory.random(),
			populationSize: populationSize,
			generations: generations,
			verbose: true,
			verboseGenerations: logInterval,
		);
		print("Found optimal factory. Fitness: ${bestFactory.fitness}");
		print(bestFactory);
	} else if ({"-d", "--debug"}.any(args.contains)) {
		debug();
	} else {
		print("Unknown arguments: $args");
	}
}

void printHelp() => print("""
	Usage: factorio.dart [-h] [-d | -e | -r [-p x] [-g y] [-l n]]

	Arguments:
		-h, --help: Display this help message and exit.
		-e, --evaluate: Evaluate the factories given in results.txt
			Helpful for when the fitness function changes and old layouts must be re-evaluated. 
		-d, --debug: Run the debug code
		-r, --run: Runs the Factory Generator with default arguments
		-p x, --population x: Generates a population size of x. Defaults to 50.
		-g y, --generations y: Runs y generations. Defaults to 50. 
		-l n, --log-interval n: Logs every z generations. Defaults to 1.

""".dedent("\t"));
