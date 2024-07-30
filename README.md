This script contains multiple test scenarios to validate the functionality of the distributed system simulation.

Explanation of Test Scenarios

Scenario 1: Successful Consensus

	•	Objective: Verify that nodes can participate in an election, choose a leader, and propose a state successfully.
	•	Steps:
	1.	All nodes participate in an election.
	2.	A leader is chosen.
	3.	The leader proposes a new state.
	•	Expected Outcome: The logs should show the election process and the successful proposal of the new state.

Scenario 2: Network Partition

	•	Objective: Test how the system handles a network partition.
	•	Steps:
	1.	Node 3 is partitioned from Node 1.
	2.	Node 2 proposes a new state.
	•	Expected Outcome: The logs should show Node 3 being partitioned and how the system handles the state proposal.

Scenario 3: Node Failure and Recovery

	•	Objective: Verify the system’s behavior during a node failure and recovery.
	•	Steps:
	1.	Node 1 fails.
	2.	Node 2 proposes a new state.
	3.	Node 1 recovers and proposes a new state.
	•	Expected Outcome: The logs should show the failure of Node 1, the state proposal by Node 2, the recovery of Node 1, and the subsequent state proposal by Node 1.

Scenario 4: Multiple Nodes Proposing New States

	•	Objective: Test the system’s behavior when multiple nodes propose new states simultaneously.
	•	Steps:
	1.	Nodes 1, 2, and 3 propose new states simultaneously.
	•	Expected Outcome: The logs should show each node’s state proposal and how the system resolves them.


