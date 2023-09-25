class TweetSerializer < ActiveModel::Serializer

  attributes :id, :uid, :text

  attribute :created do
    object.created_at.strftime("%d/%m/%Y - %H:%M:%S")
  end
end
