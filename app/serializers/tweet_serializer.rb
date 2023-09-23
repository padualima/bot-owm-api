class TweetSerializer
  include JSONAPI::Serializer

  attributes :uuid, :text, :created_at
end
