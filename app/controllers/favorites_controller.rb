class FavoritesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action do |controller|
    controller.ensure_logged_in t('layouts.notifications.you_must_log_in_to_view_this_content')
  end

  def index
    @favorite_listings = @current_user.favorite_listings
  end

  def select
    toggle_select_unselect('select')
  end

  def unselect
    toggle_select_unselect('unselect')
  end

  private

    def toggle_select_unselect(action)
      toggled = ToggleListingFavorite.call(action, listing, @current_user)
      respond_to do |format|
        format.js do
          render layout: false, template: 'favorites/favorite_select_unselect', :locals => {:listing_id => listing.id}
        end
      end
    end

    def listing
      @listing ||= Listing.find(params[:listing_id])
    end
end
