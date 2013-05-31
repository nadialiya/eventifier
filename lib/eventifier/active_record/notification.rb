require 'eventifier/notifier/notification_mixin'

module Eventifier
  class Notification < ActiveRecord::Base
    include Eventifier::NotificationMixin

    attr_accessible :event, :user

    default_scope order("notifications.created_at DESC")
    scope :for_events,  -> ids { where(event_id: ids) }
    scope :for_user,    -> user { where(user_id: user.id) }
    scope :since,       -> date { where("created_at > ?", date) }
    scope :latest,      order('notifications.created_at DESC').limit(5)
  end
end