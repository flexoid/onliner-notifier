class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :title
      t.integer :topic_id
      t.integer :last_post_id
      t.integer :last_page_id

      t.timestamps
    end
  end
end
