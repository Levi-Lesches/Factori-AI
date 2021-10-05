/// Inserts an element into the correct position in a sorted list.
void sortedInsert<E>(
	List<E> list, 
	E element, 
	num Function(E) transform, 
	{bool increasing = true}  // sorted by increasing order?
) {
	if (list.isEmpty) {
		return list.add(element);
	}
	int? insertIndex;
	for (int index = 0; index < list.length; index++) {
		if (
			(increasing && transform(list[index]) >= transform(element)) ||
			(!increasing && transform(list[index]) <= transform(element))
		) {
			insertIndex = index;
			break;
		}
	}
	list.insert(insertIndex ?? list.length - 1, element); 
}

extension Dedent on String {
	String dedent(String prefix) => splitMapJoin(
		"\n",
		onNonMatch: (String text) => text.startsWith(prefix)
			? text.substring(prefix.length)
			: text
	);
}
