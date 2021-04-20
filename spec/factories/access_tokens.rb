FactoryBot.define do
  factory :access_token do
    # token { "MyString" }
    # association :user
    user { create :user }
  end
end
