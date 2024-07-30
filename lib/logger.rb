# frozen_string_literal: true

# Manages logging of activities.
# Provides a method to retrieve the activity log.
module Logger
  # @param [Activity] the name of the activity to log
  def record_activity(activity)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    @activity_log << "[#{timestamp}] #{activity}"
  end

  def retrieve_activity_log
    @activity_log.join("\n")
  end
end
