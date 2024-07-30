require_relative 'lib/distributed_node'
require_relative 'lib/message_handler'
require_relative 'lib/partition_handler'
require_relative 'lib/logger'

# Initialize nodes
node1 = DistributedNode.new(1)
node2 = DistributedNode.new(2)
node3 = DistributedNode.new(3)

# Register peers
node1.add_neighbour(node2)
node1.add_neighbour(node3)
node2.add_neighbour(node1)
node2.add_neighbour(node3)
node3.add_neighbour(node1)
node3.add_neighbour(node2)

# Scenario 1: Successful consensus
puts 'Scenario 1: Successful Consensus'
node1.start_election
node2.start_election
node3.start_election
node1.propose_state('State A')
puts node1.retrieve_activity_log
puts node2.retrieve_activity_log
puts node3.retrieve_activity_log

# Reset logs
node1.instance_variable_set(:@activity_log, [])
node2.instance_variable_set(:@activity_log, [])
node3.instance_variable_set(:@activity_log, [])

# Scenario 2: Network partition
puts "\nScenario 2: Network Partition"
node3.simulate_partition([node1])
node2.propose_state('State B')
puts node1.retrieve_activity_log
puts node2.retrieve_activity_log
puts node3.retrieve_activity_log

# Reset logs
node1.instance_variable_set(:@activity_log, [])
node2.instance_variable_set(:@activity_log, [])
node3.instance_variable_set(:@activity_log, [])

# Scenario 3: Node failure and recovery
puts "\nScenario 3: Node Failure and Recovery"
node1.simulate_failure
node2.propose_state('State C')
node1.recover_from_failure
node1.propose_state('State D')
puts node1.retrieve_activity_log
puts node2.retrieve_activity_log
puts node3.retrieve_activity_log

# Reset logs
node1.instance_variable_set(:@activity_log, [])
node2.instance_variable_set(:@activity_log, [])
node3.instance_variable_set(:@activity_log, [])

# Scenario 4: Multiple nodes proposing new states
puts "\nScenario 4: Multiple Nodes Proposing New States"
node1.propose_state('State E')
node2.propose_state('State F')
node3.propose_state('State G')
puts node1.retrieve_activity_log
puts node2.retrieve_activity_log
puts node3.retrieve_activity_log
