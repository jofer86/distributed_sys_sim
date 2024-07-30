# frozen_string_literal: true

# Manages logging of activities.
# Provides a method to retrieve the activity log.
module Logger
  def record_activity(activity)
    @activity_log << activity
  end

  def retrieve_activity_log
    @activity_log.join("\n")
  end
end
