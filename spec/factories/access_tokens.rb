FactoryBot.define do
  factory :access_token do
    # token { "MyString" }
    user { create :user }
  end
end
