module TransactionService::Gateway
  class CouponAdapter < GatewayAdapter

    PaymentStore = StripeService::Store::StripePayment

    TransactionStore = TransactionService::Store::Transaction

    def implements_process(process)
      [:preauthorize].include?(process)
    end

    def create_payment(tx:, gateway_fields:, force_sync:)
      commission = order_commission(tx)
      total      = order_total(tx) + commission
      fee        = Money.new(0, total.currency)
      payment = {
        community_id: tx.community_id,
        transaction_id: tx.id,
        payer_id: tx.starter_id,
        receiver_id: tx.listing_author_id,
        status: :pending,
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
      result = Result::Success.new(payment)  
      SyncCompletion.new(result)      
    rescue => e
      Airbrake.notify(e)
      Result::Error.new(e.message)
    end

    def reject_payment(tx:, reason: "")
      commission = order_commission(tx)
      total      = order_total(tx) + commission
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
      result = Result::Success.new(payment)
      SyncCompletion.new(result)
    rescue => e
      Airbrake.notify(e)
      Result::Error.new(e.message)
    end

    def complete_preauthorization(tx:)
      result = Result::Success.new({})
      SyncCompletion.new(result)
    end

    def get_payment_details(tx:)
      commission = order_commission(tx)
      total      = order_total(tx)
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

    def order_commission(tx)
      TransactionService::Transaction.calculate_commission(tx.unit_price * tx.listing_quantity, tx.commission_from_seller, tx.minimum_commission)
    end       
  end
end
