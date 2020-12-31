module ListingIndexService::Search::DatabaseSearchHelper

  module_function

  def success_result(count, listings, includes)
    marketplace_configuration = Community.last.configuration
    distance_system = marketplace_configuration ? marketplace_configuration[:distance_unit].to_sym : nil
    #distance_unit = distance_system == :metric ? :km : :miles
    distance_unit = :miles

    Result::Success.new(
      { count: count, listings: listings.map { |l|
        distance_hash = parse_distance(l, distance_unit)
        ListingIndexService::Search::Converters.listing_hash(l, includes, distance_hash) 
        }
      }
    )
  end

  def parse_distance(l, distance_unit)
    distance = if distance_unit == :miles
      (l.distance / 1000) / 1.60934
    else
      (l.distance / 1000)
    end
    if(distance.present? && distance_unit.present?)
      { distance: distance, distance_unit: distance_unit }
    else
      {}
    end
  rescue
    {}
  end

  def fetch_from_db(community_id:, search:, included_models:, includes:)
    where_opts = HashUtils.compact(
      {
        community_id: community_id,
        author_id: search[:author_id],
        deleted: 0,
        listing_shape_id: Maybe(search[:listing_shape_ids]).or_else(nil)
      })
    unless search[:show_private]
      where_opts.merge!(is_private: false)
    end
    sort_order = {'Mon' => 'listings.created_at DESC', 'Tue' => 'listings.title ASC', 'Wed' => 'listings.price_cents ASC', 'Thu' => 'listings.price_cents DESC', 'Fri' => 'listings.created_at ASC', 'Sat' => 'listings.updated_at DESC', 'Sun' => 'listings.updated_at ASC'}
    query = Listing
            .where(where_opts)
            .includes(included_models)
            .order(sort_order[Date.today.strftime("%a")])
            .paginate(per_page: search[:per_page], page: search[:page])
            
    query = query.where(featured: true) if search[:featured]

    listings =
      if search[:include_closed]
        query
      else
        query.currently_open
      end
    success_result(listings.total_entries, listings, includes)
  end

  # TODO: This should probably be rethought when the Indexer and the
  # new Search API is finished and in use
  def needs_db_query?(search)
    search[:author_id].present? || search[:include_closed] == true
  end

  def needs_search?(search)
    [
      :keywords,
      :latitude,
      :longitude,
      :distance_max,
      :sort,
      :listing_shape_id,
      :categories,
      :fields,
      :price_cents
    ].any? { |field| search[field].present? }
  end

end
