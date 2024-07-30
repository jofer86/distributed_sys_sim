# froze_string_literal: true

# Simulates network partitions by isolating nodes.
# Simulates node failures and gracefully recovers nodes from failures.
module PartitionHandler
  def simulate_partition(partitioned_nodes)
    @peers -= partitioned_nodes
    partitioned_nodes.each do |node|
      node.peers -= [self]
    end
    record_activity("Simulated partition with nodes #{partitioned_nodes.map(&:identifier).join(', ')}")
  end

  def simulate_failure
    @active = false
    record_activity("Simulated failure of node #{@identifier}")
  end

  def recover_from_failure
    @active = true
    record_activity("Node #{@identifier} recovered from failure")
  end
end
