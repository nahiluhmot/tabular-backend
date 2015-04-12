require 'spec_helper'

describe Tabular::Services::Passwords do
  describe '.generate_salt' do
    let(:salt) { subject.generate_salt }

    it 'generates a random salt' do
      expect(salt).to be_a(String)
      expect(salt).to_not be_empty
    end
  end

  describe '.hash_password' do
    let(:salt) { subject.generate_salt }
    let(:password) { 'trustno1' }
    let(:hashed_password) { subject.hash_password(password, salt) }

    it 'hashes the password and salt' do
      expect(hashed_password).to be_a(String)
      expect(hashed_password).to_not be_empty
    end
  end

  describe '.validate_new_password!' do
    let(:password) { 'trustno1' }
    let(:confirmation) { password }

    context 'when the password confirmation does not match the password' do
      let(:confirmation) { 'itrustno1' }

      it 'fails with PasswordsDoNotMatch' do
        expect { subject.validate_new_password!(password, confirmation) }
          .to raise_error(Tabular::Errors::PasswordsDoNotMatch)
      end
    end

    context 'when the password confirmation matches the password' do
      context 'but the password is too short' do
        let(:password) { 'letmein' }

        it 'fails with PasswordTooShort' do
          expect { subject.validate_new_password!(password, confirmation) }
            .to raise_error(Tabular::Errors::PasswordTooShort)
        end
      end

      context 'and the passord is long enough' do
        it 'does nothing' do
          expect { subject.validate_new_password!(password, confirmation) }
            .to_not raise_error
        end
      end
    end
  end

  describe '.authenticate!' do
    let(:password) { 'trustno1' }
    let(:salt) { subject.generate_salt }
    let(:hashed_password) { subject.hash_password(password, salt) }
    let(:given_password) { password }

    context 'when the hashed password and salt do not match the given hash' do
      let(:given_password) { 'letmein' }

      it 'fails with BadPassword' do
        expect { subject.authenticate!(given_password, salt, hashed_password) }
          .to raise_error(Tabular::Errors::BadPassword)
      end
    end

    context 'when the hashed password and salt match the given hash' do
      it 'does nothing' do
        expect { subject.authenticate!(given_password, salt, hashed_password) }
          .to_not raise_error
      end
    end
  end
end
