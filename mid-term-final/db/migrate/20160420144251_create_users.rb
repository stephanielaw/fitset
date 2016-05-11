class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :username, index: true
      t.string :email
      t.string :phone
      t.datetime :birthday
      t.string :profile_pic
      t.datetime :created_at
      t.datetime :updated_at
      t.string :password_digest, null: false
      t.string :session_token, index: true
    end
  end
end
