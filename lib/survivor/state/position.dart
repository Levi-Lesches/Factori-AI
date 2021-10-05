import "dart:math";

class Position {
	static int nearThreshold = 5;
	static int limit = 100;
	static final Random _random = Random();

	final int x, y;
	const Position(this.x, this.y);
	Position.random() : 
		x = _random.nextInt(limit) * (_random.nextBool() ? 1 : -1),
		y = _random.nextInt(limit) * (_random.nextBool() ? 1 : -1);

	bool isNear(Position other) => (x - other.x).abs() < nearThreshold
		&& (y - other.y).abs() < nearThreshold;
}
