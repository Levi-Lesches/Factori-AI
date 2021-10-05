import "package:meta/meta.dart";

@immutable
class Node<T> {
	final T value;
	final List<Node<T>> children;

	const Node(this.value, this.children);

	@override
	String toString() => "Node($value)";
}
