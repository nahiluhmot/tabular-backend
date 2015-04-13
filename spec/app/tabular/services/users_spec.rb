require 'spec_helper'

describe Tabular::Services::Users do
  describe '.create_user!' do
    let(:username) { 'nahiluhmot' }
    let(:password) { 'trustno1' }
    let(:confirmation) { password }

    context 'when the password does not match its confirmation' do
      let(:confirmation) { 'itrustno1' }

      it 'fails with PasswordsDoNotMatch' do
        expect { subject.create_user!(username, password, confirmation) }
          .to raise_error(Tabular::Errors::PasswordsDoNotMatch)
      end
    end

    context 'when the password is too short' do
      let(:password) { 'letmein' }

      it 'fails with PasswordTooShort' do
        expect { subject.create_user!(username, password, confirmation) }
          .to raise_error(Tabular::Errors::PasswordTooShort)
      end
    end

    context 'when the username is too short' do
      let(:username) { '' }

      it 'fails with InvalidModel' do
        expect { subject.create_user!(username, password, confirmation) }
          .to raise_error(Tabular::Errors::InvalidModel)
      end
    end

    context 'when the username is already taken' do
      before { subject.create_user!(username, password, confirmation) }

      it 'fails with InvalidModel' do
        expect { subject.create_user!(username, password, confirmation) }
          .to raise_error(Tabular::Errors::Conflict)
      end
    end

    context 'when the username, password, and confirmation are valid' do
      let(:user) { subject.create_user!(username, password, confirmation)  }

      it 'creates a new user' do
        expect(user).to be_a(Tabular::Models::User)
        expect(user.username).to eq(username)

        Tabular::Services::Crypto.authenticate!(
          password,
          user.password_salt,
          user.password_hash
        )
      end
    end
  end

  describe '#update_password!' do
    let(:user) { create(:user) }
    let(:session) { create(:session, user: user) }

    context 'when the session is invalid' do
      it 'fails with Unauthorized' do
        expect { subject.update_password!('not a key', 'password', 'password') }
          .to raise_error(Tabular::Errors::Unauthorized)
      end
    end

    context 'when the password and confirmation doen\'t match' do
      it 'fails with PasswordsDoNotMatch' do
        expect { subject.update_password!(session.key, 'password', 'drowssap') }
          .to raise_error(Tabular::Errors::PasswordsDoNotMatch)
      end
    end

    context 'when the password can be updated' do
      it 'updates the password' do
        old_username = user.username
        old_password_salt = user.password_salt
        old_password_hash = user.password_hash
        subject.update_password!(session.key, 'password', 'password')
        user.reload
        expect(user.username).to eq(old_username)
        expect(user.password_salt).to_not eq(old_password_salt)
        expect(user.password_hash).to_not eq(old_password_hash)
      end
    end
  end

  describe '#destroy_user!' do
    context 'when the user cannot be authenticated' do
      it 'fails with Unauthorized' do
        expect { subject.destroy_user!('not a key') }
          .to raise_error(Tabular::Errors::Unauthorized)
      end
    end

    context 'when the user can be authenticated' do
      let(:user) { create(:user) }
      let(:session) { create(:session, user: user) }

      it 'destroys the user' do
        expect { subject.destroy_user!(session.key) }
          .to change { Tabular::Models::User.find_by(id: user.id) }
          .from(user)
          .to(nil)
      end
    end
  end
end
