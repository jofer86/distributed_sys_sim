# frozen_string_literal: true

# The DistributedNode class simulates a node in a distributed system
# that participates in a consensus algorithm (like Raft). Each node
# can send and receive messages, propose new states, and handle
# log replication. The class also supports leader election and
# maintains an activity log for state transitions and messages.
require_relative 'message_handler'
require_relative 'partition_handler'
require_relative 'logger'

class DistributedNode
  include MessageHandler
  include PartitionHandler
  include Logger

  attr_reader :identifier, :peers, :current_state, :term, :voted_for, :log_entries, :role, :active

  # @param identifier [Integer] the unique identifier for the node
  def initialize(identifier)
    @identifier = identifier          # Unique identifier for the node
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
  def register_peer(node)
    @peers << node unless @peers.include?(node)
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
    return unless @active

    @term += 1
    @voted_for = @identifier
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
