class NotificationServices::SlackService < NotificationService
  Label = "slack"
  Fields += [
    [:api_token, {
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
    api_token
  end

  def message_for_slack(msg)
    {
      "fallback" => fallback_message_for_hubot,
      "pretext" => "#{problem.app.name}(#{problem.environment}) - #{problem.err_class} <#{problem_url(problem)}|자세히 보기>",
      "color" => "#FF0000",
      "fields" =>
      [
       {
         "title" => "Where",
         "value" => "#{problem.where}",
         "short" => true
       },
       {
         "title" => "Count",
         "value" => problem.notices_count,
         "short" => true
       },
       {
         "title" => "Message",
         "value" => problem.message,
         "short" => false
       },
      ]
    }
  end

  def fallback_message_for_slack(problem)
    "[#{problem.app.name}][#{problem.environment}][#{problem.where}]: #{problem.error_class} <#{problem_url(problem)}|Show>"
  end

  def post_payload(problem)
    payload = {:attachments => [message_for_slack(problem)] }
    payload[:channel] = room_id unless room_id.empty?
    payload.to_json
  end

  def create_notification(problem)
    HTTParty.post(url, :body => post_payload(problem), :headers => { 'Content-Type' => 'application/json' })
  end
end
