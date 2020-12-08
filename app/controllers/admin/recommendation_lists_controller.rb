class Admin::RecommendationListsController < Admin::AdminBaseController
	def index
	end

	def new
		@recommend = RecommendationList.new
		@category = Category.all
		@listing = Listing.where(category_id: params[:category_id]) if params[:category_id].present?
	end

	def create
		
	end
	private
	def list_params
		
	end
end
