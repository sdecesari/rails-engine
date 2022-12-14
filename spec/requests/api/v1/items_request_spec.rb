require 'rails_helper'

RSpec.describe 'Items API' do 
  it 'sends a list of all items' do 
    merchant = create(:merchant)
    create_list(:item, 3, merchant_id: merchant.id)

    get '/api/v1/items'

    items = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(items[:data].count).to eq(3)

    items[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)
    end
  end 

  it 'can get one item by its id' do 
    merchant = create(:merchant)
    id = create(:item, merchant_id: merchant.id).id

    get "/api/v1/items/#{id}"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful 

    expect(item[:data]).to have_key(:id)
    expect(item[:data][:id]).to be_a(String)

    expect(item[:data][:attributes]).to have_key(:name)
    expect(item[:data][:attributes][:name]).to be_a(String)
    
    expect(item[:data][:attributes]).to have_key(:description)
    expect(item[:data][:attributes][:description]).to be_a(String)

    expect(item[:data][:attributes]).to have_key(:unit_price)
    expect(item[:data][:attributes][:unit_price]).to be_a(Float)
  end 

  it 'can create an item' do 
    merchant = create(:merchant)
    item_params = ({
      name: 'this is an item',
      description: 'hopefully this item is being created',
      unit_price: 2.5,
      merchant_id: merchant.id
    })

    headers = {"CONTENT_TYPE" => "application/json"}
    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    created_item = Item.last

    expect(response).to be_successful
    
    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.description).to eq(item_params[:description])
    expect(created_item.unit_price).to eq(item_params[:unit_price])
  end 

  it 'can edit an existing item' do 
    merchant = create(:merchant)
    id = create(:item, merchant_id: merchant.id).id 

    previous_name = Item.last.name
    item_params = {
      name: 'A new item to edit', 
      merchant_id: merchant.id
    }
    
    headers = {"CONTENT_TYPE" => "application/json"}
    patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate(item: item_params)
    item = Item.find_by(id: id)

    expect(response).to be_successful
    expect(item.name).to_not eq(previous_name)
    expect(item.name).to eq("A new item to edit")
  end 

  it 'can delete an item' do 
    merchant = create(:merchant)
    id = create(:item, merchant_id: merchant.id).id

    expect(Item.count).to eq(1)
    delete "/api/v1/items/#{id}"

    expect(response).to be_successful
    expect(Item.count).to eq(0)
    expect{Item.find(id)}.to raise_error(ActiveRecord::RecordNotFound)
  end 
end 