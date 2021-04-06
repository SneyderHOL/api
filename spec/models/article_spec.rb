require 'rails_helper'

RSpec.describe Article, type: :model do
  it "tests that article is valid" do
    article = create(:article)
    expect(article).to be_valid #article.valid? == true
  end
end
