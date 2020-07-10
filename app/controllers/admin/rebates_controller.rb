class Admin::RebatesController < Admin::AdminBaseController

  before_action :find_rebate, only: [:edit, :update, :destroy]

  def index
    @selected_left_navi_link = "rebates"
    @rebates = Rebate.order("created_at desc").paginate(:page => params[:page], :per_page => 30)
  end

  def new
    @rebate = Rebate.new
    render layout: false
  end

  def create
    @selected_left_navi_link = "rebates"
    @rebate = Rebate.new(rebate_params)
    if @rebate.save
      flash[:notice] = 'Rebate successfully create'
    else
      flash[:error] = 'Oops! Unable to create'
    end
    redirect_to admin_community_rebates_path(@current_community)
  end

  def edit
    render layout: false
  end

  def update
    @selected_left_navi_link = "rebates"
    if @rebate.update(rebate_params)
      flash[:notice] = 'Rebate successfully updated'
    else
      flash[:error] = 'Oops! Unable to update'
    end
    redirect_to admin_community_rebates_path(@current_community)
  end

  def destroy
    @selected_left_navi_link = "rebates"
    @rebate.destroy
    flash[:notice] = 'Rebate successfully deleted'
    redirect_to admin_community_rebates_path(@current_community)
  end

  private

  def find_rebate
    @rebate = Rebate.find(params[:id])
  end

  def rebate_params
    params[:rebate][:expire_on] = Date.strptime(params[:rebate][:expire_on], "%m/%d/%Y")
    params.require(:rebate).permit!
  end
end
