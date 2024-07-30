# frozen_string_literal: true

# Handles failures and partitions.
module PartitionHandler
  # @param [DistributedNodes] array of nodes so that we can incommunicate one.
  def simulate_partition(partitioned_nodes)
    partitioned_nodes.each do |node|
      remove_peer(node)
      node.remove_peer(self)
    end
    record_activity("Simulated partition with nodes #{partitioned_nodes.map(&:id).join(', ')}")
  end

  def simulate_failure
    @active = false
    record_activity("Simulated failure of node #{@id}")
  end

  def recover_from_failure
    @active = true
    record_activity("Node #{@id} recovered from failure")
  end
end
