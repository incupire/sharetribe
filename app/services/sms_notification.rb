require "twilio-ruby"

module SMSNotification
  def self.sms_service(phone_number, body)
    if APP_CONFIG.twilio_account_sid && APP_CONFIG.twilio_auth_token
      begin
        twilio_client = Twilio::REST::Client.new APP_CONFIG.twilio_account_sid, APP_CONFIG.twilio_auth_token
        twilio_client.api.account.messages.create(:from => APP_CONFIG.twilio_mobile_number, :to => phone_number, :body => body.split(/\<.*?\>/).map(&:strip).join("\n").gsub(/\s,/,','))
      rescue Exception => e
        return e.message
      end
    else
      nil
    end
  end
end