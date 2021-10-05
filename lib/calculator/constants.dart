import "package:factorio/calculator/data.dart";

class Constants {
	static const int spm = 100;
	static const List<Item> scienceProducts = [
		Item("automation-science-pack", spm/60),
		Item("logistic-science-pack", spm/60),
		Item("chemical-science-pack", spm/60),
		Item("production-science-pack", spm/60),
		Item("utility-science-pack", spm/60),
		Item("rocket-part", 1/600),
		Item("satellite", 1/60000),
	];

	static const Set<String> rawResources = {
		"water", 
		"iron-ore", 
		"copper-ore", 
		"uranium-ore", 
		"wood", 
		"stone", 
		"coal",
		"crude-oil"
	};

	static const Map<String, String> preferredRecipes = {
		"petroleum-gas": "advanced-oil-processing",
		"heavy-oil": "advanced-oil-processing", 
		"light-oil": "advanced-oil-processing",
		"solid-fuel": "solid-fuel-from-light-oil",
		"uranium-235": "kovarex-enrichment-process",
		"uranium-238": "uranium-processing",
	};

	static const Set<String> ignoredIngredients = {
		"copper-cable",
		"iron-gear-wheel",
		"pipe",
	};

	static const Set<String> productivity = {
		"sulfuric-acid",
		"basic-oil-processing",
		"advanced-oil-processing",
		"coal-liquefaction",
		"heavy-oil-cracking",
		"light-oil-cracking",
		"solid-fuel-from-light-oil",
		"solid-fuel-from-heavy-oil",
		"solid-fuel-from-petroleum-gas",
		"lubricant",
		"iron-plate",
		"copper-plate",
		"steel-plate",
		"stone-brick",
		"sulfur",
		"plastic-bar",
		"empty-barrel",
		"uranium-processing",
		"copper-cable",
		"iron-stick",
		"iron-gear-wheel",
		"electronic-circuit",
		"advanced-circuit",
		"processing-unit",
		"engine-unit",
		"electric-engine-unit",
		"uranium-fuel-cell",
		"explosives",
		"battery",
		"flying-robot-frame",
		"low-density-structure",
		"rocket-fuel",
		"nuclear-fuel",
		"nuclear-fuel-reprocessing",
		"rocket-control-unit",
		"rocket-part",
		"automation-science-pack",
		"logistic-science-pack",
		"chemical-science-pack",
		"military-science-pack",
		"production-science-pack",
		"utility-science-pack",
		"kovarex-enrichment-process",
	};

	static const Set<String> productionCells = {
		"automation-science-pack",
		"logistic-science-pack",
		"chemical-science-pack",
		"production-science-pack",
		"utility-science-pack",
		"space-science-pack",
		"low-density-structure",
		"solar-panel",
		"accumulator",
		"rail",
		"processing-unit",
		"advanced-circuit",
		"electronic-circuit",
		"heavy-oil",
		"light-oil",
		"petroleum",
		"iron-plate",
		"copper-plate",
		"steel-plate",
		"stone-brick",
		"battery",
	};
}

class ParsedConstants {
	static Map<String, Recipe> recipes;
}
