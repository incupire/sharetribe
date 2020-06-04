class Admin::CommunityHomepageController < Admin::AdminBaseController
  def homepage_settings
    @selected_left_navi_link = "homepage"
    @community = @current_community
    if request.get?
      if HomepageSection.first.present?
        @homepage = HomepageSection.first
      else
        @homepage = HomepageSection.new
      end
    else
      if HomepageSection.first.present?
        @homepage = HomepageSection.first
        @homepage.attributes = homepage_params
        @homepage.save(validate: false)
        flash[:notice] = t("admin.communities.homepage.homepage_updated_successfully")
        respond_to {|format|
          format.html
        }
      else
        @homepage = HomepageSection.new(homepage_params)
        if @homepage.save
          flash[:notice] = t("admin.communities.homepage.homepage_updated_successfully")
          respond_to {|format|
            format.html
          }
        end
      end
    end
  end

  private

  def homepage_params
    params.require(:homepage_section).permit!
  end
end