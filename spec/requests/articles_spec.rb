require 'rails_helper'

RSpec.describe ArticlesController do
  describe '#index' do
    it 'should returns a success response' do
      get '/articles'
      # expect(response.status).to eq(200)
      expect(response).to have_http_status(:ok)
    end

    it 'should returns a proper JSON' do
      article = create :article
      get '/articles'
      expect(json_data.length).to eq(1)
      expected = json_data.first
      aggregate_failures do
        expect(expected[:id]).to eq(article.id.to_s)
        expect(expected[:type]).to eq('article')
        expect(expected[:attributes]).to eq(
          title: article.title,
          content: article.content,
          slug: article.slug
        )
      end
    end

    it 'should returns articles in the proper order' do
      older_article = create :article, created_at: 1.hour.ago
      recent_article = create :article
      get '/articles'
      ids = json_data.map { |item| item[:id].to_i }
      expect(ids).to(
        eq([recent_article.id, older_article.id])
      )
    end

    it 'should paginates results' do
      article1, article2, article3 = create_list(:article, 3)
      get '/articles', params: { page: { number: 2, size: 1} }
      expect(json_data.length).to eq(1)
      expect(json_data.first[:id]).to eq(article2.id.to_s)
    end

    it 'should content pagination links in the response' do
      article1, article2, article3 = create_list(:article, 3)
      get '/articles', params: { page: { number: 2, size: 1} }
      expect(json[:links].length).to eq(5)
      expect(json[:links].keys).to contain_exactly(
        :first, :prev, :next, :last, :self
      )
    end
  end

  describe '#show' do
    let(:article) { create :article }
    subject { get "/articles/#{article.id}" }
    before { subject }

    it 'should returns a success response' do
      expect(response).to have_http_status(:ok)
    end

    it 'should returns a proper JSON' do
      expected = json_data
      aggregate_failures do
        expect(expected[:id]).to eq(article.id.to_s)
        expect(expected[:type]).to eq('article')
        expect(expected[:attributes]).to eq(
          title: article.title,
          content: article.content,
          slug: article.slug
        )
      end
    end
  end

  describe '#create' do
    subject { post '/articles' }
    context 'when no code provided' do
      it_behaves_like 'forbidden requests'
    end

    context 'when invalid code provided' do
      headers = { 'authorization' => 'Invalid token' }
      it_behaves_like 'forbidden requests'
    end

    context 'when authorized' do
      context 'when invalid parameters provided' do
        let(:access_token) { create :access_token }
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '',
                content: ''
              }
            }
          }
        end
        subject {
          post '/articles',
          params: invalid_attributes,
          headers: { 'authorization' => "Bearer #{access_token.token}" }
        }
        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end
        
        it 'should return proper error json' do
          headers = { 'authorization' => "Bearer #{access_token.token}" }
          subject
          expect(json[:errors]).to include(
            {
              :status => 422,
              :source => { :pointer => "/data/attributes/title" },
              :title => "Invalid request",
              :detail => ["can't be blank"]
            },
            {
              :status => 422,
              :source => { :pointer => "/data/attributes/content" },
              :title => "Invalid request",
              :detail => ["can't be blank"]
            },
            {
              :status => 422,
              :source => { :pointer => "/data/attributes/slug" },
              :title => "Invalid request",
              :detail => ["can't be blank"]
            }
          )
        end
      end
    end

    context 'when success request sent' do
      let(:access_token) { create :access_token }
      let(:valid_attributes) do
        {
          data: {
            attributes: {
              title: 'Awesome article',
              content: 'Super content',
              slug: 'awesome-article'
            }
          }
        }
      end
      subject {
        post '/articles',
        params: valid_attributes,
        headers: { 'authorization' => "Bearer #{access_token.token}" }
      }

      it 'should have 201 status code' do
        subject
        expect(response).to have_http_status(:created)
      end

      it 'should have proper json body' do
        subject
        expect(json_data[:attributes]).to include(
          valid_attributes[:data][:attributes])
      end

      it 'should create the article' do
        expect{ subject }.to change{ Article.count }.by(1)
      end
    end
  end

  describe '#update' do
    let(:article) { create :article }
    subject { patch "/articles/#{article.id}" }
    
    context 'when no code provided' do
      it_behaves_like 'forbidden requests'
    end

    context 'when invalid code provided' do
      headers = { 'authorization' => 'Invalid token' }
      it_behaves_like 'forbidden requests'
    end

    context 'when authorized' do
      context 'when invalid parameters provided' do
        let(:access_token) { create :access_token }
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '',
                content: ''
              }
            }
          }
        end
        subject {
          patch "/articles/#{article.id}",
          params: invalid_attributes,
          headers: { 'authorization' => "Bearer #{access_token.token}" }
        }
        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end
        
        it 'should return proper error json' do
          headers = { 'authorization' => "Bearer #{access_token.token}" }
          subject
          expect(json[:errors]).to include(
            {
              :status => 422,
              :source => { :pointer => "/data/attributes/title" },
              :title => "Invalid request",
              :detail => ["can't be blank"]
            },
            {
              :status => 422,
              :source => { :pointer => "/data/attributes/content" },
              :title => "Invalid request",
              :detail => ["can't be blank"]
            }
          )
        end
      end
    end

    context 'when success request sent' do
      let(:access_token) { create :access_token }
      let(:valid_attributes) do
        {
          data: {
            attributes: {
              title: 'Awesome article',
              content: 'Super content',
              slug: 'awesome-article'
            }
          }
        }
      end
      subject {
        patch "/articles/#{article.id}",
        params: valid_attributes,
        headers: { 'authorization' => "Bearer #{access_token.token}" }
      }

      it 'should have 200 status code' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'should have proper json body' do
        subject
        expect(json_data[:attributes]).to include(
          valid_attributes[:data][:attributes])
      end

      it 'should update the article' do
        subject
        expect(article.reload.title).to eq(
          valid_attributes[:data][:attributes][:title]
        )
      end
    end
  end
end
