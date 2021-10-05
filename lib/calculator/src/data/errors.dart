class MultipleRecipesError extends Error {
	final String item;
	MultipleRecipesError(this.item);	

	@override
	String toString() => "Multiple recipes found for $item";
}

class NoRecipeError extends Error {
	final String item;
	NoRecipeError(this.item);	

	@override
	String toString() => "No recipe found for $item";
}
