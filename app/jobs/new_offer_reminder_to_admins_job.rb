class NewOfferReminderToAdminsJob < Struct.new(:listing_id, :community_id)


  include DelayedAirbrakeNotification

   def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform(*args)
    # Do something later
    listing = Listing.find(listing_id)
    community = Community.find(community_id)

    if community.new_offer_reminder_to_admins?
      community.admins.each do |admin|
        email = PersonMailer.new_offer_reminder_notification_to_admins(listing, community, admin)
        if email.present?
          MailCarrier.deliver_now(email)
        end
      end
    end
  end
end