FactoryGirl.define do
  factory :tab, class: Tabular::Models::Tab do
    sequence(:artist) { |n| "test_artist_#{n}" }
    sequence(:album) { |n| "test_album_#{n}" }
    sequence(:title) { |n| "test_title_#{n}" }
    body <<-EOS
      e |-----------------|
      B |-----------------|
      G |-------------3-3-|
      D |-3--3-3-xxxx-3-3-|
      A |-3--3-3-xxxx-1-1-|
      E |-1--1-1-xxxx-----|
    EOS

    user
  end
end
