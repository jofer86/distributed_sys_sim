# frozen_string_literal: true

require_relative 'message_handler'
require_relative 'partition_handler'
require_relative 'logger'

# The DistributedNode class simulates a node in a distributed system
# that participates in a consensus algorithm (like Raft). Each node
# can send and receive messages, propose new states, and handle
# log replication. The class also supports leader election and
# maintains an activity log for state transitions and messages.
class DistributedNode
  include MessageHandler
  include PartitionHandler
  include Logger

  attr_reader :id, :peers, :current_state, :term, :voted_for, :log_entries, :role, :active

  # Initialize a node with a unique id
  #
  # @param id [Integer] the unique id for the node
  def initialize(id)
    @id = id                          # Unique id for the node
    @peers = []                       # List of neighboring nodes (peers)
    @current_state = nil              # Current state of the node
    @activity_log = []                # Log to record messages and state transitions
    @term = 0                         # Current term
    @voted_for = nil                  # Candidate voted for in current term
    @log_entries = []                 # Log entries for state machine
    @role = :follower                 # Node's role (follower, candidate, leader)
    @active = true                    # Node's active status (true = active, false = failed)
  end

  # @param node [DistributedNode] the peer node to be added
  def add_neighbour(node)
    @peers << node unless @peers.include?(node)
  end

  # @param node [DistributedNode] the peer node to be removed
  def remove_peer(node)
    @peers.delete(node)
  end

  # @param new_state [Object] the new state to propose
  def propose_state(new_state)
    @current_state = new_state
    record_activity("Suggested new state: #{@current_state}")
    @log_entries << { term: @term, state: @current_state }
    return unless @role == :leader

    @peers.each do |peer|
      transmit_message(peer, { type: 'append_entries', term: @term, entries: [{ term: @term, state: @current_state }] })
    end
  end

  def start_election
    return unless @active

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
end
