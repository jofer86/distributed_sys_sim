class DistributedNode
  attr_reader :id, :peers, :current_state, :activity_logs

  def initialize(id)
    @id = id
    @peers = []
    @current_state = nil
    @activity_logs = []
  end

  def comunicate_message(target_node, message)
    if @peers.include?(target_node)
      target_node.get_message(self, message)
      record_activity("Transmitted message to Node #{to_node.identifier}: #{message}")
    else
      record_activity("Failed to transmit message to Node #{to_node.identifier}: Not a peer")
    end
  end

  def get_message(from_node, message)
    record_activity("Message from Node #{from_node.id}: #{message}")
    handle_message(from_node, message)
  end

  def handle_message(from_node, message)
    # to include processing consensus messages, state updates, and all those things.
  end

  def suggest_state(new_state)
    @current_state = new_state
    record_activity("Suggested new state: #{@current_state}")

    pears.each do |peer|
      comunicate_message(peer, "Suggested state:  #{@current_state5}")
    end
  end

  def record_activity(activity)
    @activity_log << activity
  end

  def retreive_activity_log
    @activity_log.join('\n')
  end
end
