import "dart:io";

import "package:http/http.dart";

class Downloader {
	static const String recipeUrl = "https://raw.githubusercontent.com/wube/factorio-data/master/base/prototypes/recipe.lua";

	final Client client = Client();

	void dispose() {
		client.close();
	}

	Future<void> downloadRecipes() async {
		final Response response = await client.get(recipeUrl);
		final String content = response.body;
		List<String> lines = content.split("\n");
		lines = lines.sublist(1, lines.length - 2);
		lines [0] = "local data = ${lines [0]}";
		lines.add("return data");
		final File recipesScript = File("data/recipes.lua");
		await recipesScript.writeAsString(lines.join("\n"));
	}

	Future<void> exportToJson() async {
		final ProcessResult result = await Process.run(
			"lua.exe", 
			["parse_recipes.lua"],
			workingDirectory: Directory.current.path,
		);
		final String stderr = result.stderr;
		if (stderr.trim().isNotEmpty) {
			throw FormatException(stderr, "data/recipes.lua");
		}
	}
}
