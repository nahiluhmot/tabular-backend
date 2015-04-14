FactoryGirl.define do
  factory :relationship, class: Tabular::Models::Relationship do
    follower
    followee
  end
end
