json.last_read_at current_user.notifications_last_read_at
json.notifications @notifications do |notification|
  json.id notification.id
  json.html render_partial_view(notification, :dropdown)
end