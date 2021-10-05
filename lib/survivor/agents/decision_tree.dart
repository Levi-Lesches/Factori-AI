import "agent.dart";

class DecisionTree { }

class DecisionTreeLearningAgent extends Agent { 
	static void generateTrainingData();

	static void train();

	static DecisionTree loadTree();

	final DecisionTree tree;
	DecisionTreeLearningAgent() : tree = loadTree();
}
