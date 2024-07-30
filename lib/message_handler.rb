# frozen_string_literal: true

# The message handler module is in charge to handle comunications between peer nodes.
# Manages vote requests, vote responses, and log replication (append entries).
module MessageHandler
  def transmit_message(target_node, message)
    return unless @active

    unless @peers.include?(target_node)
      record_activity("Failed to transmit message to Node #{target_node.id}: Not a peer")
      return
    end

    target_node.receive_message(self, message)
    record_activity("Transmitted #{format_message(message)} to Node #{target_node.id}")
  end

  def receive_message(from_node, message)
    return unless @active

    record_activity("Received #{format_message(message)} from Node #{from_node.id}")
    handle_message(from_node, message)
  end

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

  def handle_vote_response(_from_node, message)
    return unless message[:vote_granted]

    @votes ||= 0
    @votes += 1
    become_leader if @votes > @peers.size / 2
  end

  def handle_append_entries(from_node, message)
    unless message[:term] >= @term
      transmit_message(from_node, { type: 'append_entries_response', term: @term, success: false })
      return
    end

    @term = message[:term]
    @role = :follower
    @log_entries += message[:entries]
    transmit_message(from_node, { type: 'append_entries_response', term: @term, success: true })
  end

  private

  def format_message(message)
    case message[:type]
    when 'vote_request'
      "vote request (term: #{message[:term]})"
    when 'vote_response'
      "vote response (term: #{message[:term]}, vote granted: #{message[:vote_granted]})"
    when 'append_entries'
      "append entries (term: #{message[:term]}, entries: #{message[:entries]})"
    when 'append_entries_response'
      "append entries response (term: #{message[:term]}, success: #{message[:success]})"
    else
      message.to_s
    end
  end
end
