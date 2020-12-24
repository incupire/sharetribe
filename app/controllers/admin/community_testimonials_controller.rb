class Admin::CommunityTestimonialsController < Admin::AdminBaseController
  include Collator
  before_action :set_service
  def index
    @selected_left_navi_link = "testimonials"
  end

  private

  def set_service
    @service = Admin::TestimonialsService.new(
      community: @current_community,
      params: params)
  end
end
