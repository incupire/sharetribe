class RebuildWhenUpdate < Struct.new(:community_id)

  include DelayedAirbrakeNotification

  def perform
    system "RAILS_ENV=#{Rails.env} bundle exec rake ts:rebuild"
  end
end
