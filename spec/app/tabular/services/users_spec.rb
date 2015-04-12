require 'spec_helper'

describe Tabular::Services::Users do
  describe '.create' do
    let(:username) { 'nahiluhmot' }
    let(:password) { 'trustno1' }
    let(:confirmation) { password }

    context 'when the password does not match its confirmation' do
      let(:confirmation) { 'itrustno1' }

      it 'fails with InvalidModel' do
        expect { subject.create(username, password, confirmation) }
          .to raise_error(Tabular::Errors::InvalidModel)
      end
    end

    context 'when the password is too short' do
      let(:password) { 'letmein' }

      it 'fails with InvalidModel' do
        expect { subject.create(username, password, confirmation) }
          .to raise_error(Tabular::Errors::InvalidModel)
      end
    end

    context 'when the username is too short' do
      let(:username) { '' }

      it 'fails with InvalidModel' do
        expect { subject.create(username, password, confirmation) }
          .to raise_error(Tabular::Errors::InvalidModel)
      end
    end

    context 'when the username is already taken' do
      before { subject.create(username, password, confirmation) }

      it 'fails with InvalidModel' do
        expect { subject.create(username, password, confirmation) }
          .to raise_error(Tabular::Errors::InvalidModel)
      end
    end

    context 'when the username, password, and confirmation are valid' do
      let(:user) { subject.create(username, password, confirmation)  }

      it 'creates a new user' do
        expect(user).to be_a(Tabular::Models::User)
        expect(user.username).to eq(username)

        Tabular::Services::Passwords.authenticate!(
          password,
          user.password_salt,
          user.password_hash
        )
      end
    end
  end
end
