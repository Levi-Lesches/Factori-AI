import "actions/action.dart";
import "actions/collect.dart";
import "actions/craft.dart";
import "actions/goto.dart";
import "actions/mine.dart";
import "actions/shoot.dart";
import "actions/smelt.dart";

import "state.dart";
import "state/furnace.dart";

export "actions/action.dart";

class Actions {
	static const List<Action> possibleActions = [
		CollectPlates(),  // removes plates from furnace
		Craft("ammo"),    // crafts an ammo from plates
		GoTo(Furnace.position),  // walks to the smelter
		GoTo(State.ironPatchPosition),  // walks to the iron patch
		Mine(),   // mines some iron ore
		Shoot(),  // shoots a nearby biter
		Smelt(),  // inserts ore into the furnace
	];
}