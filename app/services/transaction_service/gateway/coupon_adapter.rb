module TransactionService::Gateway
  class CouponAdapter < GatewayAdapter

    PaymentStore = StripeService::Store::StripePayment

    TransactionStore = TransactionService::Store::Transaction

    def implements_process(process)
      [:preauthorize].include?(process)
    end

    def create_payment(tx:, gateway_fields:, force_sync:)
      commission = order_commission(tx)
      total      = order_total(tx)
      fee        = Money.new(0, total.currency)
      marketplace_txn_percentage_fee = marketplace_txn_percentage_fee(tx)

      if commission > 0 && marketplace_txn_percentage_fee[:commission_from_seller] > 0
        avon_commission_charge = stripe_api.stripe_customer_charge(
          community: tx.community,
          cust_id: tx.buyer.stripe_customer_id,
          amount: commission.cents,
          currency: commission.currency.iso_code,
          description: "Avontage Bucks commission for transaction - #{tx.id}",
          is_captured: false,
          metadata: {
            buyer: "#{tx.buyer.primary_email.address}",
            seller: "#{tx.seller.primary_email.address}",
            transaction_id: "#{tx.id}"
          })

        tx.update_attribute(:avon_commission_charge_id, avon_commission_charge.id)
      end

      payment = {
        community_id: tx.community_id,
        transaction_id: tx.id,
        payer_id: tx.starter_id,
        receiver_id: tx.listing_author_id,
        status: :pending,
        sum:  total,
        commission: Money.new(0, total.currency), #TODO Commission should be zero for seller in case of coupon payment!
        fee: fee,
        real_fee: nil,
        subtotal: total - fee,
        stripe_charge_id: nil,
        stripe_transfer_id: nil,
        transfered_at: nil,
        available_on: nil
      }
      result = Result::Success.new(payment)  
      SyncCompletion.new(result)      
    rescue => e
      Airbrake.notify(e)
      Result::Error.new(e.message)
    end

    def reject_payment(tx:, reason: "")
      commission = order_commission(tx)
      total      = order_total(tx)
      fee        = Money.new(0, total.currency)
      payment = {
        community_id: tx.community_id,
        transaction_id: tx.id,
        payer_id: tx.starter_id,
        receiver_id: tx.listing_author_id,
        status: :canceled,
        sum:  total,
        commission: Money.new(0, total.currency), #Commission should be zero for seller in case of coupon payment!
        fee: fee,
        real_fee: nil,
        subtotal: total - fee,
        stripe_charge_id: nil,
        stripe_transfer_id: nil,
        transfered_at: nil,
        available_on: nil
      }

      if tx.avon_commission_charge_id.present?
        stripe_api.cancel_charge(
          community: tx.community_id,
          charge_id: tx.avon_commission_charge_id,
          account_id: nil,
          reason: reason,
          metadata: {sharetribe_transaction_id: tx.id}
        )
      end
      result = Result::Success.new(payment)
      SyncCompletion.new(result)
    rescue => e
      Airbrake.notify(e)
      Result::Error.new(e.message)
    end

    def complete_preauthorization(tx:)
      if tx.avon_commission_charge_id.present?
        charge = stripe_api.capture_charge(community: tx.community_id, charge_id: tx.avon_commission_charge_id, seller_id: nil)
      end
      result = Result::Success.new({})
      SyncCompletion.new(result)
    rescue => e
      Airbrake.notify(e)
      Result::Error.new(e.message)
    end

    def get_payment_details(tx:)
      commission = order_commission(tx)
      total      = order_total(tx) + commission #avon_commission = commission
      fee        = Money.new(0, total.currency)
      payment = {
        sum: total,
        commission: commission,
        real_fee: fee,
        subtotal: total - fee,
      }

      # in case of :destination payments, gateway fee is always charged from admin account, we cannot know it upfront, as transfer to seller = total - commission, is immediate
      # in case of :separate payments, gateway fee is charged from admin account, but then deducted from seller on delayed transfer
      gateway_fee = Money.new(0, payment[:sum].currency)

      {
        payment_total:       payment[:sum],
        total_price:         payment[:subtotal],
        charged_commission:  payment[:commission],
        payment_gateway_fee: gateway_fee
      }      
    end

    private

    def order_total(tx)
      shipping_total = Maybe(tx.shipping_price).or_else(0)
      tx.unit_price * tx.listing_quantity + shipping_total
    end

    def marketplace_txn_percentage_fee(tx)
      TransactionService::API::Api.settings.get(community_id: tx[:community_id], payment_gateway: "stripe", payment_process: "preauthorize")[:data]      
    end

    def order_commission(tx)
      TransactionService::Transaction.calculate_commission(tx.unit_price * tx.listing_quantity, tx.commission_from_seller, tx.minimum_commission)
    end

    def stripe_api
      StripeService::API::Api.wrapper
    end       
  end
end
