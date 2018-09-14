class Admin::CommunityListingsController < Admin::AdminBaseController

  def index
    @selected_left_navi_link = "listings"
    @listings = resource_scope.order("#{sort_column} #{sort_direction}")
      .paginate(:page => params[:page], :per_page => 30)
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
    end
  end

  def sort_direction
    params[:direction] == 'asc' ? 'asc' : 'desc'
  end
end
