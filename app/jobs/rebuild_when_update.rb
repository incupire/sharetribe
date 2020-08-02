class RebuildWhenUpdate < Struct.new(:community_id)

  include DelayedAirbrakeNotification

  def perform
    exec "RAILS_ENV=production bundle exec rake ts:rebuild"
  end
end


