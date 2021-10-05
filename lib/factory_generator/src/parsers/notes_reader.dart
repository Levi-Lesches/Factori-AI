import "dart:io" show File;

/// Reads data from the notes file.
class NotesReader {
	/// The file with the notes.
	static File notesFile = File("factorio.txt.yaml");

	/// All the lines of the file as a list. 
	static List<String> get lines => notesFile.readAsStringSync().split("\n").map(
		(_) => _.trimRight()
	).toList(growable: false);

	/// Only the lines between the BEGIN and END lines.
	static List<String> get relevantLines { 
		int start, end;
		for (final MapEntry<int, String> entry in lines.asMap().entries) {
			final int index = entry.key;
			final String line = entry.value;
			if (line == "BEGIN") {
				start = index;
			} else if (line == "END") {
				end = index;
			}
		}
		return lines.sublist(start + 1, end);
	}


}
