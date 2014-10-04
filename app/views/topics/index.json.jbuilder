json.array!(@topics) do |topic|
  json.extract! topic, :id, :title, :topic_id, :last_post_id
  json.url topic_url(topic, format: :json)
end
