require 'fcm'

module PushNotification
  def self.send_notification(recipient, message_body)
    puts "Inside the push Notificaiton method"

    fcm = FCM.new(APP_CONFIG.fcm_api_key)
    
    if recipient.android_device_token.present?
      device_token = recipient.android_device_token

      options = {
        data: {
          title: "Avontage",
          info: "Notification"
        },
        notification: {
          title: "Avontage Notification",
          body: message_body,
          sound: "default",
        },
        priority: "high"
      }
      
      response = fcm.send([device_token], options)
      body = JSON.parse(response[:body])
      status = true if body["success"] == 1

      if status
        puts "Push Notification is successful", status
      else
        puts "Push Notification is failed", status
      end
    else
      puts "No Device Found!!"
    end
  rescue Exception => e
    puts e.message 
  end

end
