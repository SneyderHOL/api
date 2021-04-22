require 'rails_helper'

RSpec.describe "/comments", type: :request do
  let(:article) { create :article }
  
  describe "GET /index" do
    subject { get article_comments_url(article_id: article.id), as: :json }
    it "renders a successful response" do
      # get "/articles/#{article.id}/comments", as: :json
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return only comments belonging to article' do
      comment = create :comment, article: article
      create :comment
      subject
      expect(json_data.length).to eq(1)
      expect(json_data.first[:id]).to eq(comment.id.to_s)
    end

    it 'should paginate results' do
      comments = create_list :comment, 3, article: article
      get article_comments_url(
        article_id: article.id,
        page: { 'size' => '1', 'number' => '2' }
      ), as: :json
      expect(json_data.length).to eq(1)
      comment = comments.second
      expect(json_data.first[:id]).to eq(comment.id.to_s)
    end

    it 'should have proper json body' do
      comment = create :comment, article: article
      subject
      expect(json_data.first[:attributes]).to eq({content: comment.content})
    end

    it 'should have related objects information in the response' do
      user = create :user
      comment = create :comment, article: article, user: user
      subject
      relationship = json_data.first[:relationships]
      expect(relationship[:article][:data][:id]).to eq(article.id.to_s)
      expect(relationship[:user][:data][:id]).to eq(user.id.to_s)
      
    end
  end

  describe "POST /create" do
    context 'when not authorized' do
      subject { post article_comments_url(article_id: article.id) }
      it_behaves_like 'forbidden requests'
    end

    context 'when authorized' do
      let(:user) { create :user }
      let(:access_token) { user.create_access_token }
      let(:valid_attributes) do 
        { data: { attributes: { content: 'My awesome comment for article' } } }
      end
      let(:invalid_attributes) { { data: { attributes: { content: '' } } } }
      let(:valid_headers) do
        { 'authorization' => "Bearer #{access_token.token}" }
      end      
      context "with valid parameters" do
        subject {
          post article_comments_url(article_id: article.id),
                params: valid_attributes.merge(article_id:article.id),
                headers: valid_headers, as: :json
        }
        
        it "returns 201 status code" do
          subject
          expect(response).to have_http_status(:created)
        end

        it "creates a new Comment" do
          expect { subject }.to change(article.comments, :count).by(1)
        end

        it "renders a JSON response with the new comment" do
          subject
          expect(json_data[:attributes]).to eq({
            content: 'My awesome comment for article'
          })
        end
      end
  
      context "with invalid parameters" do
        subject {
          post article_comments_url(article_id: article.id),
                params: invalid_attributes.merge(article_id:article.id),
                headers: valid_headers, as: :json
        }

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "does not create a new Comment" do
          expect { subject }.to change(Comment, :count).by(0)
        end
  
        it "renders a JSON response with errors for the new comment" do
          subject
          expect(json[:errors]).to include({
            :status => 422,
            :source => { :pointer => "/data/attributes/content" },
            :title => "Invalid request",
            :detail => ["can't be blank"]  
          })
        end
      end
    end
  end
end
