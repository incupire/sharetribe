class ConfirmConversation
  # How many days before transaction is automatically confirmed should we send a reminder?
  REMIND_DAYS_BEFORE_CLOSING = 2

  def initialize(transaction, user, community)
    @transaction = transaction
    @conversation = transaction.conversation
    @user = user
    @participation = @conversation.participations.find_by_person_id(user.id)
    @offerer = transaction.seller
    @requester = transaction.buyer
    @community = community
  end

  # Listing confirmed by user
  def confirm!
    Delayed::Job.enqueue(TransactionConfirmedJob.new(@transaction.id, @community.id))
    add_amount_to_seller(@transaction.id)
    [3, 10].each do |send_interval|
      Delayed::Job.enqueue(TestimonialReminderJob.new(@transaction.id, nil, @community.id), :priority => 9, :run_at => send_interval.days.from_now)
    end
  end

  # Listing canceled by user
  def cancel!
    Delayed::Job.enqueue(TransactionCanceledJob.new(@transaction.id, @community.id))
  end

  def update_participation(feedback_given)
    @participation.update_attribute(:is_read, true) if @offerer.eql?(@user)

    if @transaction.author == @user
      @transaction.update_attributes(author_skipped_feedback: true) unless feedback_given
    else
      @transaction.update_attributes(starter_skipped_feedback: true) unless feedback_given
    end
  end

  def activate_automatic_confirmation!
    automatic_confirmation_at = @transaction.automatic_confirmation_after_days.days.from_now

    automatic_confirmation_job!(automatic_confirmation_at)
    confirmation_reminder_job!(automatic_confirmation_at)
  end

  def activate_automatic_booking_confirmation_at!(automatic_confirmation_at)
    Delayed::Job.enqueue(AutomaticBookingConfirmationJob.new(@transaction.id, @user.id, @community.id), run_at: automatic_confirmation_at, priority: 7)
  end

  private

  def automatic_confirmation_job!(automatic_confirmation_at)
    Delayed::Job.enqueue(AutomaticConfirmationJob.new(@transaction.id, @user.id, @community.id), run_at: automatic_confirmation_at, priority: 7)
  end

  def confirmation_reminder_job!(automatic_confirmation_at)
    reminder_email_at           = automatic_confirmation_at - REMIND_DAYS_BEFORE_CLOSING.days
    activate_reminder           = @transaction.automatic_confirmation_after_days > REMIND_DAYS_BEFORE_CLOSING

    if activate_reminder
      Delayed::Job.enqueue(ConfirmReminderJob.new(@transaction.id, @requester.id, @community.id, REMIND_DAYS_BEFORE_CLOSING), :priority => 9, :run_at => reminder_email_at)
    end
  end

  def add_amount_to_seller(transaction_id)
    transaction = Transaction.find(transaction_id)
    return unless transaction.payment_gateway == :coupon_pay
    seller_gets = order_total(transaction)
    seller = transaction.author
    if seller.coupon_balance_cents.present?
      seller.coupon_balance += seller_gets   
    else
      seller.coupon_balance = seller_gets
    end
    if seller.save
      create_avon_bucks_history(seller_gets, seller, "added", transaction)
    end     
    transaction.toggle!(:coupon_bal_refunded)
  end

  def create_avon_bucks_history(amount, person, operation, transaction)
    AvonBucksHistory.create(
      amount: amount,
      operation: operation,
      remaining_balance: person.coupon_balance,
      person_id: person.id,
      transaction_id: transaction.id
    )
  end

  def order_total(tx)
    shipping_total = Maybe(tx.shipping_price).or_else(0)
    tx.unit_price * tx.listing_quantity + shipping_total
  end

end
