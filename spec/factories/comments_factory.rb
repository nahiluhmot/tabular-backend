FactoryGirl.define do
  factory :comment, class: Tabular::Models::Comment do
    body 'Great tab!'
    user
    tab
  end
end
