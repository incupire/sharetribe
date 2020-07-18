module ExportTransaction
  extend ActiveSupport::Concern

  def last_activity
    [last_transition_at, conversation&.last_message_at].compact.max
  end

  included do
    class << self
      def for_community_sorted_by_column(community_id, sort_column, sort_direction, limit, offset, params)
        sort_column = "transactions.#{sort_column}" if sort_column.index('.').nil?
        tx_scope = exist.by_community(community_id)
        if params.present?
          if params[:start_date].present? && params[:end_date].present?
            start_date = Date.strptime(params[:start_date],"%m/%d/%Y")
            end_date = Date.strptime(params[:end_date],"%m/%d/%Y")
            tx_scope = tx_scope.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
          end

          if params[:status].present?
            tx_scope = tx_scope.where(current_state: params[:status])
          end
        end
        tx_scope = tx_scope.with_payment_conversation.includes(:listing).limit(limit).offset(offset).order("#{sort_column} #{sort_direction}")
        tx_scope
      end

      def for_community_sorted_by_activity(community_id, sort_direction, limit, offset, eager_includes = false, params)
        tx_scope = exist.by_community(community_id)
        if params.present?
          if params[:start_date].present? && params[:end_date].present?
            start_date = Date.strptime(params[:start_date],"%m/%d/%Y")
            end_date = Date.strptime(params[:end_date],"%m/%d/%Y")
            tx_scope = tx_scope.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
          end

          if params[:status].present?
            tx_scope = tx_scope.where(current_state: params[:status])
          end
        end
        tx_scope = tx_scope.with_payment_conversation_latest(sort_direction).limit(limit).offset(offset)
        tx_scope = tx_scope.for_csv_export if eager_includes
        tx_scope
      end
    end
  end
end
