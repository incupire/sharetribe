env :PATH, ENV['PATH']

set :output, {error: "log/cron_error_log.log", standard: "log/cron_log.log"}

every 1.day, :at => '12:00 pm' do
  runner "CommunityMailer.deliver_community_updates"
end

every :hour do
  command "cd /home/ubuntu/apps/avontage && RAILS_ENV=#{Rails.env} bundle exec script/delayed_job restart"
end

every 2.hours do
  command "cd /home/ubuntu/apps/avontage && RAILS_ENV=#{Rails.env} bundle exec rake ts:rebuild"
end
