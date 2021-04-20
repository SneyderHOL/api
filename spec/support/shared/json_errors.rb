require 'rails_helper'

shared_examples_for "unauthorized_requests" do
  let(:authentication_error) do
    {
      :status => "401",
      :source => { :pointer => "/code"},
      :title => "Authentication code is invalid",
      :detail => "You must provide valid code in order to exchange it for token."
    }
  end

  subject { post :create }

  it 'should return 401 status code' do
    subject
    expect(response).to have_http_status(401)
  end

  it 'should return proper error body' do
    subject
    expect(json[:errors]).to include(authentication_error)
  end
end

shared_examples_for 'forbidden requests' do
  let(:authorization_error) do
    [{
      :status => "403",
      :source => { :pointer => "/headers/authorization"},
      :title => "Not authorized",
      :detail => "You have no right to access this resource."
    }]
  end
  
  it 'should return 403 status code' do
    subject
    expect(response).to have_http_status(:forbidden)
  end

  it 'should return proper error json' do
    subject
    expect(json[:errors]).to eq(authorization_error)
  end
end
