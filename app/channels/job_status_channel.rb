class JobStatusChannel < ApplicationCable::Channel
  def subscribed
    stream_from "job_status"
  end

  def unsubscribed
    # Cleanup se necessário
  end
end
