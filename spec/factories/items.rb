FactoryBot.define do
  factory :item do
    name { Faker::Beer.name }
    description { Faker::Lorem.sentence }
    unit_price { Faker::Commerce.price }
  end
end
