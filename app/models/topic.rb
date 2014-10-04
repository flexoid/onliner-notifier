class Topic < ActiveRecord::Base
  validates :title, :topic_id, presence: true
end
