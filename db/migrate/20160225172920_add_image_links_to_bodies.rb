class AddImageLinksToBodies < ActiveRecord::Migration
  def change
    add_column :stars, :image_url, :string
    add_column :worlds, :image_url, :string
  end
end
