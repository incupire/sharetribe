class ConfirmConversationsController < ApplicationController

  before_action do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_confirm_or_cancel")
  end

  before_action :fetch_conversation
  before_action :fetch_listing

  before_action :ensure_is_starter, except: [:cancel_coupon_pay]
  before_action :ensure_current_is_admin, only: [:cancel_coupon_pay]

  def confirm
    return redirect_to person_transaction_path(person_id: @current_user.id, message_id: @listing_transaction.id) unless in_valid_pre_state?

    conversation =      @listing_transaction.conversation
    other_person =      @listing_transaction.other_party(@current_user)

    render(locals: {
      action_type: "confirm",
      message_form: Message.new,
      listing_transaction: @listing_transaction,
      can_be_confirmed: can_be_confirmed?,
      other_person: other_person,
      status: @listing_transaction.status,
      form: @listing_transaction
    })
  end

  def cancel
    unless in_valid_pre_state?
      return redirect_to person_transaction_path(person_id: @current_user.id, message_id: @listing_transaction.id)
    end

    conversation =      @listing_transaction.conversation
    other_person =      @listing_transaction.other_party(@current_user)

    render(:confirm, locals: {
      action_type: "cancel",
      message_form: Message.new,
      listing_transaction: @listing_transaction,
      can_be_confirmed: can_be_confirmed?,
      other_person: other_person,
      status: @listing_transaction.status,
      form: @listing_transaction
    })
  end

  # Handles confirm and cancel forms
  def confirmation
    status = params[:transaction][:status].to_sym

    if !TransactionService::StateMachine.can_transition_to?(@listing_transaction.id, status)
      flash[:error] = t("layouts.notifications.something_went_wrong")
      return redirect_to person_transaction_path(person_id: @current_user.id, message_id: @listing_transaction.id)
    end


    msg = parse_message_param()
    transaction = complete_or_cancel_tx(@current_community.id, @listing_transaction.id, status, msg, @current_user.id)

    give_feedback = Maybe(params)[:give_feedback].select { |v| v == "true" }.or_else { false }

    confirmation = ConfirmConversation.new(@listing_transaction, @current_user, @current_community)
    confirmation.update_participation(give_feedback)

    flash[:notice] = t("layouts.notifications.offer_#{status}")

    redirect_path =
      if give_feedback
        new_person_message_feedback_path(:person_id => @current_user.id, :message_id => @listing_transaction.id)
      else
        person_transaction_path(:person_id => @current_user.id, :id => @listing_transaction.id)
      end

    redirect_to redirect_path
  end

  def cancel_coupon_pay
    tx = Transaction.find(params[:id])
    buyer_gets = order_total(tx)
    buyer = tx.starter
    buyer_coupon_bal = buyer.coupon_balance.present? ? ((buyer.coupon_balance_cents/100).to_f + (buyer_gets.cents/100).to_f) : (buyer_gets.cents/100).to_f
    if buyer.update_attribute(:coupon_balance, buyer_coupon_bal)
      tx.toggle!(:coupon_bal_refunded)
      flash[:notice] = "Coupon balance refunded successfully!"
    else
      flash[:notice] = "Something went wrong please try later!"
    end
    redirect_to person_transaction_path(:person_id => @current_user.id, :id => tx.id)    
  end

  private

  def order_total(tx)
    shipping_total = Maybe(tx.shipping_price).or_else(0)
    tx.unit_price * tx.listing_quantity + shipping_total
  end

  def complete_or_cancel_tx(community_id, tx_id, status, msg, sender_id)
    if status == :confirmed
      TransactionService::Transaction.complete(community_id: community_id, transaction_id: tx_id, message: msg, sender_id: sender_id)
    else
      TransactionService::Transaction.cancel(community_id: community_id, transaction_id: tx_id, message: msg, sender_id: sender_id)
    end
  end

  def parse_message_param
    if(params[:message])
      message = Message.new(params.require(:message).permit(:content).merge({ conversation_id: @listing_transaction.conversation.id }))
      if(message.valid?)
        message.content
      end
    end
  end

  def ensure_is_starter
    unless @listing_transaction.starter == @current_user
      flash[:error] = "Only listing starter can perform the requested action"
      redirect_to (session[:return_to_content] || root)
    end
  end

  def ensure_current_is_admin
    unless @current_user.has_admin_rights?(@current_community)
      flash[:error] = "Only admin can perform the requested action"
      redirect_to (session[:return_to_content] || root)
    end
  end  

  def fetch_listing
    @listing = @listing_transaction.listing
  end

  def fetch_conversation
    @listing_transaction = @current_community.transactions.find(params[:id])
  end

  def in_valid_pre_state?
    can_be_confirmed? || can_be_canceled?
  end

  def can_be_confirmed?
    TransactionService::StateMachine.can_transition_to?(@listing_transaction.id, :confirmed)
  end

  def can_be_canceled?
    TransactionService::StateMachine.can_transition_to?(@listing_transaction.id, :canceled)
  end

end
