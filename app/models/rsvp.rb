class Rsvp < ActiveRecord::Base
  belongs_to :user
  belongs_to :meetup

  # validates_uniqueness_of :meetup_id
  validates :user_id,
  presence: true

  validates :meetup_id,
  presence: true
end
