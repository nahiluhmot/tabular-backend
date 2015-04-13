FactoryGirl.define do
  factory :user, class: Tabular::Models::User do
    sequence(:username) { |n| "test_user_#{n}" }

    # For efficiency, use the same password salt and hash in every test.
    salt = Tabular::Services::Passwords.generate_salt
    hash = Tabular::Services::Passwords.hash_password('password', salt)
    password_salt salt
    password_hash hash
  end
end
