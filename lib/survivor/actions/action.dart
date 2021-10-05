import "package:factorio/survivor/state.dart";

export "package:factorio/survivor/state.dart";

abstract class Action {
	State execute(State state);
	bool isValid(State state); 
	const Action();
} 
