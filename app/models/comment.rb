class Comment < ApplicationRecord
  belongs_to :article
  belongs_to :user

  validates :content, presence: true
  # scope :recent, -> { order(created_at: :desc) }
end
