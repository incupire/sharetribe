class TransactionConfirmedJob < Struct.new(:conversation_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    transaction = Transaction.find(conversation_id)
    community = Community.find(community_id)
    MailCarrier.deliver_now(PersonMailer.transaction_confirmed(transaction, community))

    if transaction.payment_gateway == :stripe
      payment = StripeService::Store::StripePayment.get(community_id, transaction.id)
      default_available = APP_CONFIG.stripe_payout_delay.to_f.days.from_now
      available_date = (payment[:available_on] || default_available) + 24.hours
      case StripeService::API::Api.wrapper.charges_mode(community_id)
      when :destination then Delayed::Job.enqueue(StripePayoutJob.new(transaction.id, community_id), :priority => 9, :run_at => available_date)
      when :separate then Delayed::Job.enqueue(StripePayoutJob.new(transaction.id, community_id), :priority => 9)
      end
    elsif transaction.payment_gateway == :coupon_pay
      ###### The marketplace Transaction Fee is charged to the BUYERs credit card for coupon pay transaction ######
      commission_amount = order_commission(transaction)
      begin
        stripe_customer_charge = StripeService::API::StripeApiWrapper.stripe_customer_charge(
                                          community: community,
                                          cust_id: transaction.buyer.stripe_customer_id,
                                          amount: commission_amount.cents,
                                          currency: commission_amount.currency.iso_code,
                                          description: "Avon-BUCKS commission for transaction - #{transaction.id}",
                                          is_captured: true,
                                          metadata: {
                                            buyer: "#{transaction.buyer.primary_email.address}",
                                            seller: "#{transaction.seller.primary_email.address}",
                                            transaction_id: "#{transaction.id}"
                                          }
                                        )       
      rescue Exception => e
        error(self, e)
      end
    end
  end

  private
    def order_commission(tx)
      TransactionService::Transaction.calculate_commission(tx.unit_price * tx.listing_quantity, tx.commission_from_seller, tx.minimum_commission)
    end
end
