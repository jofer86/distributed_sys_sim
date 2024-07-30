# frozen_string_literal: true

# The DistributedNode class simulates a node in a distributed system
# that participates in a consensus algorithm (Raft). Each node
# can send and receive messages, propose new states, and handle
# log replication. The class also supports leader election and
# maintains an activity log for state transitions and messages.
class DistributedNode
  attr_reader :id, :peers, :current_state, :activity_logs

  # @param id [Integer] the unique identifier for the node
  def initialize(id)
    @id = id
    @peers = []
    @current_state = nil
    @activity_logs = []
    @term = 0
    @voted_for = nil
    @log_entries = []
    @role = :follower
  end

  # @param target_node [DistributedNode] the peer node to send the message to
  # @param message [Hash] the message to be sent
  def comunicate_message(target_node, message)
    if @peers.include?(target_node)
      target_node.get_message(self, message)
      record_activity("Transmitted message to Node #{to_node.id}: #{message}")
    else
      record_activity("Failed to transmit message to Node #{to_node.id}: Not a peer")
    end
  end

  # @param from_node [DistributedNode] the peer node that sent the message
  # @param message [Hash] the message received
  def get_message(from_node, message)
    record_activity("Message from Node #{from_node.id}: #{message}")
    handle_message(from_node, message)
  end

  # @param from_node [DistributedNode] the peer node that sent the message
  # @param message [Hash] the message to handle
  def handle_message(from_node, message)
    case message[:type]
    when 'vote_request'
      handle_vote_request(from_node, message)
    when 'vote_response'
      handle_vote_response(from_node, message)
    when 'append_entries'
      handle_append_entries(from_node, message)
    end
  end

  def handle_vote_request(from_node, message)
    if message[:term] > @term
      @term = message[:term]
      @voted_for = from_node.id
      transmit_message(from_node, { type: 'vote_response', term: @term, vote_granted: true })
    else
      transmit_message(from_node, { type: 'vote_response', term: @term, vote_granted: false })
    end
  end

  # @param from_node [DistributedNode] the peer node that sent the vote request
  # @param message [Hash] the vote request message
  def handle_vote_response(_from_node, message)
    return unless message[:vote_granted]

    @votes ||= 0
    @votes += 1
    become_leader if @votes > @peers.size / 2
  end

  # @param from_node [DistributedNode] the peer node that sent the vote response
  # @param message [Hash] the vote response message
  def handle_append_entries(from_node, message)
    if message[:term] >= @term
      @term = message[:term]
      @role = :follower
      @log_entries += message[:entries]
      transmit_message(from_node, { type: 'append_entries_response', term: @term, success: true })
    else
      transmit_message(from_node, { type: 'append_entries_response', term: @term, success: false })
    end
  end

  # @param new_state [Object] the new state to propose
  def suggest_state(new_state)
    @current_state = new_state
    record_activity("Suggested new state: #{@current_state}")
    @log_entries << { term: @term, state: @current_state }
    return unless @role == :leader

    @peers.each do |peer|
      transmit_message(peer, { type: 'append_entries', term: @term, entries: [{ term: @term, state: @current_state }] })
    end
  end

  def start_election
    @term += 1
    @voted_for = @id
    @role = :candidate
    @votes = 1
    record_activity("Started election for term #{@term}")

    @peers.each do |peer|
      transmit_message(peer, { type: 'vote_request', term: @term })
    end
  end

  def become_leader
    @role = :leader
    record_activity("Became leader for term #{@term}")
  end

  # @param activity [String] the activity to log
  def record_activity(activity)
    @activity_log << activity
  end

  def retrieve_activity_log
    @activity_log.join("\n")
  end

  # @param partitioned_nodes [Array<DistributedNode>] the nodes to be isolated
  def simulate_partition(partitioned_nodes)
    @peers -= partitioned_nodes
    partitioned_nodes.each do |node|
      node.peers -= [self]
    end
    record_activity("Simulated partition with nodes #{partitioned_nodes.map(&:identifier).join(', ')}")
  end
end
