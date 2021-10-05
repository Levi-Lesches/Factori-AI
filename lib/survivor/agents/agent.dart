import "package:factorio/survivor/actions.dart";
import "package:factorio/survivor/state.dart";

export "package:factorio/survivor/actions.dart";
export "package:factorio/survivor/state.dart";

abstract class Agent {
	Action getAction(State state);
}
