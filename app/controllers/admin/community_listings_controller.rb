require "csv"
class Admin::CommunityListingsController < Admin::AdminBaseController

  def index
    @selected_left_navi_link = "listings"

    respond_to do |format|
      format.html do
        @listings = resource_scope.order("#{sort_column} #{sort_direction}")
                .paginate(:page => params[:page], :per_page => 30)        
      end

      format.csv do
        all_listings = resource_scope

        marketplace_name = @current_community.use_domain ? @current_community.domain : @current_community.ident

        self.response.headers["Content-Type"] ||= 'text/csv'
        self.response.headers["Content-Disposition"] = "attachment; filename=#{marketplace_name}-listings-#{Date.today}.csv"
        self.response.headers["Content-Transfer-Encoding"] = "binary"
        self.response.headers["Last-Modified"] = Time.now.ctime.to_s

        self.response_body = Enumerator.new do |yielder|
          generate_csv_for(yielder, all_listings, @current_community)
        end
      end
    end
  end

  def destroy
    listing = Listing.find(params[:id])
    listing.update(
      # Delete listing info
      description: nil,
      origin: nil,
      open: false,
      deleted: true
    )
    listing.location&.destroy
    ListingImage.where(listing_id: listing.id).destroy_all
    flash[:notice] = "Listing deleted successfully!"
    redirect_to admin_community_listings_path(@current_community, sort: "updated")
  end

  def featured
    listing = Listing.find(params[:id])
    listing.toggle!(:featured)

    if request.xhr?
      render json: {status: listing.featured}
    else
      redirect_to admin_community_listings_path(@current_community, sort: "updated")
    end
  end

  private

  def resource_scope
    @current_community.listings.exist.includes(:author, :category)
  end

  def sort_column
    case params[:sort]
    when 'started'
      'listings.created_at'
    when 'updated', nil
      'listings.updated_at'
    when 'category'
      'categories.url'
    when 'featured'
      'listings.featured'
    end
  end

  def sort_direction
    params[:direction] == 'asc' ? 'asc' : 'desc'
  end

  def generate_csv_for(yielder, all_listings, community)
    # first line is column names
    header_row = %w{
      title
      author
      created_at
      updated_at
      category
      status
      featured
      price
      monthly_availability
    }

    unless @current_user.is_manager?
      yielder << header_row.to_csv(force_quotes: true)
      unless all_listings.blank?
        all_listings.each do |listing|
          expired = listing.valid_until && listing.valid_until < DateTime.current
          custom_field_name = listing.custom_field_values.select{|value| value.question.name.eql?("MONTHLY AVAILABILITY")}.first
          value = custom_field_name.display_value if custom_field_name.present?
          listing_data = {
            title: listing.title,
            author: PersonViewUtils.person_display_name(listing.author, community),
            created_at: listing.created_at,
            updated_at: listing.updated_at,
            category: listing.category.display_name(I18n.locale),
            status: expired ? 'expired' : (listing.open? ? 'open' : 'closed'),
            featured: listing.featured?,
            price: MoneyViewUtils.to_humanized(listing.price),
            monthly_availability: value.present? ? value : nil
          }
          data = listing_data.clone
          yielder << data.values.to_csv(force_quotes: true)
        end
      end
    end
  end  
end
