require 'csv'

class Admin::CommunityMembershipsController < Admin::AdminBaseController

  def index
    @selected_left_navi_link = "manage_members"
    @community = @current_community
    user_fields = FeatureFlagHelper.feature_enabled?(:user_fields)

    respond_to do |format|
      format.html do
        @memberships = CommunityMembership.where(community_id: @current_community.id, status: ["accepted", "banned", "pending_email_confirmation"])
                                           .includes(person: :emails)
                                           .paginate(page: params[:page], per_page: 50)
                                           .order("#{sort_column} #{sort_direction}")
        if params[:q].present?
          query = <<-SQL
          community_memberships.person_id IN
          (SELECT p.id FROM people p LEFT OUTER JOIN emails e ON e.person_id = p.id
           WHERE p.given_name like ? OR p.family_name like ? OR p.display_name like ? OR e.address like ?)
          SQL
          like_q = "%#{params[:q]}%"
          @memberships = @memberships.where(query, like_q, like_q, like_q, like_q)
        end
      end
      format.csv do
        all_memberships = CommunityMembership.where(community_id: @community.id)
                                              .where("status != 'deleted_user'")
                                              .includes(person: [:emails, :location])
        marketplace_name = if @community.use_domain
          @community.domain
        else
          @community.ident
        end

        self.response.headers["Content-Type"] ||= 'text/csv'
        self.response.headers["Content-Disposition"] = "attachment; filename=#{marketplace_name}-users-#{Date.today}.csv"
        self.response.headers["Content-Transfer-Encoding"] = "binary"
        self.response.headers["Last-Modified"] = Time.now.ctime.to_s

        self.response_body = Enumerator.new do |yielder|
          generate_csv_for(yielder, all_memberships, @community, user_fields)
        end
      end
    end
  end

  def ban
    membership = CommunityMembership.find_by(id: params[:id], community_id: @current_community.id)

    if membership.person == @current_user
      flash[:error] = t("admin.communities.manage_members.ban_me_error")
      return redirect_to admin_community_community_memberships_path(@current_community)
    end

    membership.update_attributes(status: "banned")
    membership.update_attributes(admin: 0) if membership.admin == 1

    @current_community.close_listings_by_author(membership.person)

    if request.xhr?
      render json: {status: membership.status}
    else
      redirect_to admin_community_community_memberships_path(@current_community)
    end
  end

  def unban
    membership = CommunityMembership.find_by(id: params[:id], community_id: @current_community.id)
    membership.update_attributes(status: "accepted")
    if request.xhr?
      render json: {status: membership.status}
    else
      redirect_to admin_community_community_memberships_path(@current_community)
    end
  end

  def promote_admin
    unless @current_user.is_manager?
      if removes_itself?([params[:remove_admin]], @current_user)
        render body: nil, status: 405
      else
        person = Person.find_by(id: params[:remove_admin])
        if params[:add_admin].eql?('Manager')
          @current_community.community_memberships.where(person_id: params[:remove_admin]).update_all("admin = 0")
          person.update(is_manager: true)
        elsif params[:add_admin].eql?('Admin')
          @current_community.community_memberships.where(person_id: params[:remove_admin]).update_all("admin = 1")
          person.update(is_manager: false)
        elsif params[:add_admin].eql?('None')
          @current_community.community_memberships.where(person_id: params[:remove_admin]).update_all("admin = 0")
          person.update(is_manager: false)
        end
        render body: nil, status: 200
      end
    else
      render body: nil, status: 405
    end  
  end

  def manually_confirm_email_address
    if params[:allowed_to_confirm].present?
      Email.where(person_id: params[:allowed_to_confirm]).update_all(confirmed_at: Time.now)
      person = Person.find_by(id: params[:allowed_to_confirm])
      membership = person.community_memberships.where(:status => "pending_email_confirmation").first
      membership.update_attribute(:status, "accepted") rescue nil
    end

    if params[:disallowed_to_confirm].present?
      Email.where(person_id: params[:disallowed_to_confirm]).update_all(confirmed_at: nil)
      person = Person.find_by(id: params[:disallowed_to_confirm])
      membership = person.community_memberships.where(:status => "accepted").first
      membership.update_attribute(:status, "pending_email_confirmation") rescue nil
    end
    render body: nil, status: 200
  end

  def posting_allowed
    @current_community.community_memberships.where(person_id: params[:allowed_to_post]).update_all("can_post_listings = 1")
    @current_community.community_memberships.where(person_id: params[:disallowed_to_post]).update_all("can_post_listings = 0")

    render body: nil, status: 200
  end

  def post_requests_allowed
    @current_community.community_memberships.where(person_id: params[:allowed_to_request]).update_all("can_post_requests = 1")
    @current_community.community_memberships.where(person_id: params[:disallowed_to_request]).update_all("can_post_requests = 0")

    render body: nil, status: 200
  end

  def dms_allowed
    @current_community.community_memberships.where(person_id: params[:allowed_to_dms]).update_all("can_send_dms = 1")
    @current_community.community_memberships.where(person_id: params[:disallowed_to_dms]).update_all("can_send_dms = 0")

    render body: nil, status: 200
  end

  def set_verified
    Person.where(id: params[:allowed_to_verified]).update_all(is_verified: true)
    Person.where(id: params[:disallowed_to_verified]).update_all(is_verified: false)
    render body: nil, status: 200
  end

  def set_activated
    Person.where(id: params[:allowed_to_active]).update_all(is_active: true)
    Person.where(id: params[:disallowed_to_active]).update_all(is_active: false)
    render body: nil, status: 200
  end

  def set_level
    Person.where(id: params[:user_id]).update_all(user_level: params[:user_role])
    render body: nil, status: 200
  end

  def add_coupon_balance
    unless @current_user.is_manager?
      currency = @current_community.currency
      person = Person.find(params[:id])
      cents = MoneyUtil.parse_str_to_subunits(params[:coupon_balance_cents], currency)
      if person.coupon_balance_cents.present?
        person.coupon_balance += MoneyUtil.to_money(cents, currency)
      else
        person.coupon_balance = MoneyUtil.to_money(cents, currency)
      end
      if person.save
        create_avon_bucks_history(person, cents, "added")
      end
    else
      flash[:error] = 'Your are not authorized to perform this action'
    end
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  def deduct_coupon_balance
    unless @current_user.is_manager?
      currency = @current_community.currency
      person = Person.find(params[:id])
      cents = MoneyUtil.parse_str_to_subunits(params[:coupon_balance_cents], currency)
      if person.coupon_balance_cents.present? && (person.coupon_balance_cents >= cents)
        person.coupon_balance -= MoneyUtil.to_money(cents, currency)
        if person.save
          create_avon_bucks_history(person, cents, "deducted")
        end
        flash[:error] = nil
      else
        flash[:error] = "Deduction balance should not be greater than available balance!"
      end
    else
      flash[:error] = 'Your are not authorized to perform this action'
    end
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  def destroy
    unless @current_user.is_manager?
      membership = CommunityMembership.find_by(id: params[:id], community_id: @current_community.id)
      person = membership.person
      person.destroy
      flash[:notice] = 'User deleted successfully!'
    else
      flash[:error] = 'Your are not authorized to perform this action'
    end
    redirect_to admin_community_community_memberships_path(@current_community)
  end   

  private

  def generate_csv_for(yielder, memberships, community, user_fields_enabled)
    # first line is column names
    header_row = %w{
      first_name
      last_name
      display_name
      username
      phone_number
      address
      email_address
      email_address_confirmed
      joined_at
      status
      is_admin
      accept_emails_from_admin
      language
      coupon_balance
    }
    header_row.push("can_post_offers") if community.require_verification_to_post_listings
    header_row.push("can_post_requests") if community.require_verification_to_post_request
    header_row.push("can_send_dms") if community.require_verification_to_send_direct_message

    unless @current_user.is_manager?
      if user_fields_enabled
        header_row += community.person_custom_fields.map{|f| f.name}
      end
      yielder << header_row.to_csv(force_quotes: true)
      memberships.find_each do |membership|
        user = membership.person
        unless user.blank?
          user_data = {
            first_name: user.given_name,
            last_name: user.family_name,
            display_name: user.display_name,
            username: user.username,
            phone_number: user.phone_number,
            address: user.location ? user.location.address : "",
            email_address: nil,
            email_address_confirmed: nil,
            joined_at: membership.created_at,
            status: membership.status,
            is_admin: membership.admin,
            accept_emails_from_admin: nil,
            language: user.locale,
            coupon_balance: user.coupon_balance.present? ? (user&.coupon_balance_cents/100).to_f : ""
          }
          user_data[:can_post_offers] = membership.can_post_listings if community.require_verification_to_post_listings
          user_data[:can_post_requests] = membership.can_post_requests if community.require_verification_to_post_request
          user_data[:can_send_dms] = membership.can_send_dms if community.require_verification_to_send_direct_message
          if user_fields_enabled
            community.person_custom_fields.each do |field|
              field_value = user.custom_field_values.by_question(field).first
              user_data[field.name] = field_value.try(:display_value)
            end
          end
          user.emails.each do |email|
            accept_emails_from_admin = user.preferences["email_from_admins"] && email.send_notifications
            data = user_data.clone
            data[:email_address] = email.address
            data[:email_address_confirmed] = !!email.confirmed_at
            data[:accept_emails_from_admin] = !!accept_emails_from_admin
            yielder << data.values.to_csv(force_quotes: true)
          end
        end
      end
    end  
  end

  def removes_itself?(ids, current_admin_user)
    ids ||= []
    ids.include?(current_admin_user.id) && (current_admin_user.is_marketplace_admin?(@current_community) || current_admin_user.is_manager?)
  end

  def sort_column
    case params[:sort]
    when "name"
      "people.given_name"
    when "coupon_balance"
      "people.coupon_balance_cents"
    when "display_name"
      "people.display_name"
    when "email"
      "emails.address"
    when "join_date"
      "created_at"
    when "posting_allowed"
      "can_post_listings"
    when "post_requests_allowed"
      "can_post_requests"
    when "dms_allowed"
      "can_send_dms"
    else
      "created_at"
    end
  end

  def sort_direction
    if params[:direction] == "asc"
      "asc"
    else
      "desc" #default
    end
  end

  def create_avon_bucks_history(person, cents, operation)
    AvonBucksHistory.create(
      amount: MoneyUtil.to_money(cents, @current_community.currency),
      operation: operation,
      remaining_balance: person.coupon_balance,
      person_id: person.id,
      operator_id:  @current_user.id
    )    
  end
end
