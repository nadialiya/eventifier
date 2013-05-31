class Eventifier::NotificationMapping
  class << self
    include ObjectHelper
  end

  def self.add(key, relation)
    notification_mappings[key] = relation
  end

  def self.find(key)
    notification_mappings[key]
  end

  def self.all
    notification_mappings
  end

  def self.users_for(event, key)
    method_from_relation(event.eventable, find(key))
  end

  private
  def self.notification_mappings
    @notification_mapppings ||= {}
  end
end