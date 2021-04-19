require 'rails_helper'

RSpec.describe AccessTokensController, type: :controller do
  describe '#create' do
    context 'when invalid requests' do
      let(:error) do
        {
          :status => "401",
          :source => { :pointer => "/code"},
          :title => "Authentication code is invalid",
          :detail => "You must provide valid code in order to exchange it for token."
        }
      end

      it 'should return 401 status code' do
        post :create
        expect(response).to have_http_status(401)
      end

      it 'should return proper error body' do
        post :create
        # expect(json).to eq(1)
        expect(json[:errors]).to include(error)
      end
    end

    context 'when success requests' do
      
    end
  end
end
