class Repository < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :path, :public
end
