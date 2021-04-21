class CommentSerializer
  include JSONAPI::Serializer
  attributes :content
  belongs_to :article
  belongs_to :user
  #has_one :article
  #has_one :user
end
