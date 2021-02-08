namespace :sharetribe do

  namespace :community_updates do
    desc "Sends the community updates email to everyone who should receive it now"
    task :deliver => :environment do |t, args|
      CommunityMailer.deliver_community_updates
    end
  end

  namespace :landing_pages do
    desc "Install sample landing page into initializers/landing_page.rb"
    task :install_static => :environment do
      source = File.join(Rails.root, "app", "services", "custom_landing_page", "example_data.rb")
      dest = File.join(Rails.root, "config", "initializers", "landing_page.rb")

      # patch example_data
      text = File.read(source)
      text = text.gsub(/ExampleData/, "StaticData")
      # dont copy TEMPLATE_STR
      text = text.gsub(/^\s*TEMPLATE_STR = <<JSON.*JSON/m, "")
      File.open(dest, "w") {|file| file.puts text }

      puts "Created config/initializers/landing_page.rb with static template."
      puts "This needs clp_static_enabled: true in config.yml for it to take effect."
    end
  end

  desc "Cleans the auth_tokens table in the DB by deleting expired ones"
  task :delete_expired_auth_tokens => :environment do
    AuthToken.delete_expired
  end

  desc "Retries set express checkouts"
  task :retry_and_clean_paypal_tokens => :environment do
    Delayed::Job.enqueue(PaypalService::Jobs::RetryAndCleanTokens.new(1.hour.ago))
  end

  desc "Synchnorizes verified email address states from SES to local DB"
  task :synchronize_verified_with_ses => :environment do
    EmailService::API::Api.addresses.enqueue_batch_sync()
  end

  desc "Update total received review of person"
  task :update_total_review => :environment do
    Person.find_each do |person|
      person.update_column(:total_received_review, person.received_testimonials.size)
    end  
  end

  desc "Update progress bar for existing user"
  task :update_progress_bar => :environment do
    Person.find_each do |person|
      if person.stripe_customer_id.present?
        person.profile_progress[:enable_purchasing] = 20
      end
      if StripeAccount.where(person_id: person.id).present?
        person.profile_progress[:enable_selling] = 20
      end
      person.profile_progress[:notifications] = 20
      person.profile_progress[:user_profile] = 20 if person.profile_progress[:user_profile] == 14
      person.save
    end
  end

  desc "Update progress bar for existing user with new column"
  task :update_progress_bar_with_new_field => :environment do
    Person.find_each do |person|
      person.profile_progress_info[:contact_info]      = person.profile_progress[:user_profile]/2
      person.profile_progress_info[:user_profile]      = person.profile_progress[:user_profile]/2
      person.profile_progress_info[:notifications]     = person.profile_progress[:notifications]
      person.profile_progress_info[:enable_purchasing] = person.profile_progress[:enable_purchasing]
      person.profile_progress_info[:enable_selling]    =  person.profile_progress[:enable_selling]
      person.save
      puts "==============#{person.username}============profile_progress_info: #{person.profile_progress_info}"
    end
  end

  desc "Update progress bar with new calculation for existing users"
  task :update_progress_bar_with_new_calculation => :environment do
    Person.find_each do |person|
      person.profile_progress_info[:contact_info] = 25 if person.profile_progress_info[:contact_info] > 0
      person.profile_progress_info[:user_profile] = 25 if person.profile_progress_info[:user_profile] > 0
      person.profile_progress_info[:enable_purchasing] = 25 if person.profile_progress_info[:enable_purchasing] > 0
      person.profile_progress_info[:notifications] = 0
      person.profile_progress_info[:enable_selling] = 0
      person.save
      puts "==============#{person.username}============profile_progress_info: #{person.profile_progress_info}"
    end
  end

  namespace :person_custom_fields do
    desc "Copying person's phone number to custom fields"
    task :copy_phone_number_community, [:community_ident] => :environment do |t, args|
      community_ident = args[:community_ident]
      if community_ident.blank?
        raise 'Invalid marketplace ident.'
      end
      community = Community.find_by!(ident: community_ident)
      PersonPhoneCopyist.copy_community(community)
    end

    desc "Remove person's phone number from custom fields"
    task :remove_phone_number_community, [:community_ident] => :environment do |t, args|
      community_ident = args[:community_ident]
      if community_ident.blank?
        raise 'Invalid marketplace ident.'
      end
      community = Community.find_by!(ident: community_ident)
      community.person_custom_fields.phone_number.destroy_all
    end
  end
end
