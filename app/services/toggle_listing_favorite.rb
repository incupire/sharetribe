class ToggleListingFavorite
  ACTIONS = %w(select unselect).freeze

  def initialize(action, listing, user)
    @action = action
    @listing = listing
    @user = user
  end

  def self.call(action, listing, user)
    new(action, listing, user).call
  end

  def call
    return unless ACTIONS.include?(@action)
    send(@action)
  end

  private

  def select
    return if @user.is_favorite?(@listing.id)
    @user.favorite_listings << @listing
  end

  def unselect
    return unless @user.is_favorite?(@listing.id)
    @user.favorite_listings.delete(@listing)
  end
end
