if APP_CONFIG.use_thinking_sphinx_indexing.to_s.casecmp("true") == 0
  ThinkingSphinx::Index.define :listing, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do

    #Thinking Sphinx will automatically add the SQL command SET NAMES utf8 as
    # part of the indexing process if the database connection settings have
    # encoding set to utf8. This is default in Rails but with Heroku, we need to
    # be explicit.
    set_property :utf8? => true

    # limit to open listings
    where "listings.open = '1' AND listings.deleted = '0' AND (listings.valid_until IS NULL OR listings.valid_until > now())"

    # fields
    indexes title
    indexes description
    indexes custom_field_values(:text_value), :as => :custom_text_fields
    indexes origin_loc.google_address
    indexes author.display_name, :as => :display_name
    indexes author.given_name, :as => :first_name
    indexes author.tags, :as => :author_tags
    indexes tags

    # attributes
    has id, :as => :listing_id # id didn't work without :as aliasing
    has price_cents
    has created_at, updated_at
    has sort_date
    has author.is_verified, :as => :is_verified
    has author.total_received_review, :as => :total_received_review
    has category(:id), :as => :category_id
    has listing_shape_id
    has community_id
    has custom_dropdown_field_values.selected_options.id, :as => :custom_dropdown_field_options, :type => :integer, :multi => true
    has custom_checkbox_field_values.selected_options.id, :as => :custom_checkbox_field_options, :type => :integer, :multi => true
    has "RADIANS(locations.latitude)",  :as => :latitude,  :type => :float
    has "RADIANS(locations.longitude)", :as => :longitude, :type => :float

    set_property :enable_star => true

    set_property :field_weights => {
      :title       => 10,
      :tags        => 9,
      :category    => 8,
      :display_name => 7,
      :first_name  => 6,
      :author_tags => 5,
      :description => 3
    }
    group_by 'latitude', 'longitude'

  end
end
