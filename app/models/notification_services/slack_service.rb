class NotificationServices::SlackService < NotificationService
  Label = "slack"
  Fields += [
    [:webhook_url, {
      :placeholder => 'URL',
      :label => 'Slack Incoming Webhook URL'
    }],
    [:room_id, {
      :placeholder => '#general',
      :label => 'Room where Slack should notify'
    }]
  ]

  def check_params
    if Fields.detect {|f| self[f[0]].blank? unless f[0] == :room_id }
      errors.add :base, "You must specify your Slack Incoming Webhook URL."
    end
  end

  def url
    webhook_url
  end

  def message_for_slack(problem)
    "[#{problem.app.name}][#{problem.environment}][#{problem.where}]: #{problem.error_class} <#{problem_url(problem)}|Show>"
  end

  def post_payload(problem)
    payload = {:text => message_for_slack(problem) }
    payload[:channel] = room_id unless room_id.empty?
    payload.to_json
  end

  def create_notification(problem)
    HTTParty.post(webhook_url, :body => post_payload(problem), :headers => { 'Content-Type' => 'application/json' })
  end
end
