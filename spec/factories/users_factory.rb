FactoryGirl.define do
  factory :user, class: Tabular::Models::User do
    sequence(:username) { |n| "test_user_#{n}" }
    password_salt { Tabular::Services::Passwords.generate_salt }
    password_hash do
      Tabular::Services::Passwords.hash_password('password', password_salt)
    end
  end
end
