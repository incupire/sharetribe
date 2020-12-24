class Admin::RecommendationListsController < Admin::AdminBaseController
  def index
    @recommendation_list = RecommendationList.order(:sortpriorty)
    if params[:recommend_id].present?
      @recommendation_list = RecommendationList.find(params[:recommend_id])
      @recommendation_list.active ? @recommendation_list.update(active: false) : @recommendation_list.update(active: true)
      render layout: false
    end
    @selected_left_navi_link = 'recommendation_lists'
  end

  def new
    @recommendation_list = RecommendationList.new
    @category = Category.all
    if params[:category_id].present?
      @listing = Listing.where(category_id: params[:category_id])
      render layout: false
    end
  end

  def edit
    @recommendation_list = RecommendationList.find(params[:id])
    @category = Category.all
    if params[:category_id].present?
      @listing = Listing.where(category_id: params[:category_id]) 
      render layout: false
    end
  end

  def update
    @recommendation_list = RecommendationList.find(params[:id]) 
    if @recommendation_list.update(list_params)
      @recommendation_list.recommendation_list_listings.destroy_all
      params[:recommendation_list][:listing_ids].each do |listing|
        @recommendation_list.recommendation_list_listings.create(listing_id: listing)
      end
    end
    redirect_to admin_recommendation_lists_path
  end

  def destroy
    @recommendation_list = RecommendationList.find(params[:id])
    @recommendation_list.destroy
    redirect_to admin_recommendation_lists_path
  end

  def create
    @recommendation_list = RecommendationList.new(list_params)
    if @recommendation_list.save
      params[:recommendation_list][:listing_ids].each do |listing|
        @recommendation_list.recommendation_list_listings.create(listing_id: listing)
      end
      redirect_to admin_recommendation_lists_path
    else
      render 'new'
    end 
  end

  def order
    new_sort_order = params[:order].map(&:to_i).each_with_index
    order_recommendation_list!(new_sort_order)
    render body: nil, status: 200
  end

  private
    def list_params
      params.require(:recommendation_list).permit(:recommendation_code,:recommendation_title,:active, listing_ids: [])
    end


  def order_recommendation_list!(sort_priorities)
    base =  "sortpriorty = CASE id\n"
    update_statements = sort_priorities.reduce(base) do |sql, (cat_id, priority)|
      sql + "WHEN #{cat_id} THEN #{priority}\n"
    end
    update_statements += "END"

    RecommendationList.update_all(update_statements)
  end
end
