require 'rails_helper'

describe UserAuthenticator do
  context 'when initilized with code' do
    let(:authenticator) { described_class.new(code: 'sample') }
    let(:authenticator_class) { UserAuthenticator::Oauth }

    describe '#initialized' do
      it 'should initialize proper authenticator' do
        expect(authenticator_class).to receive(:new).with('sample')
        authenticator
      end
    end
  end

  context 'when initilized with login & password' do
    let(:authenticator) { described_class.new(login: 'jsmith', password: 'secret') }
    let(:authenticator_class) { UserAuthenticator::Standard }

    describe '#initialized' do
      it 'should initialize proper authenticator' do
        expect(authenticator_class).to receive(:new).with('jsmith', 'secret')
        authenticator
      end
    end
  end
end
