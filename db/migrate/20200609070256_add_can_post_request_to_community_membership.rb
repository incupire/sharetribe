class AddCanPostRequestToCommunityMembership < ActiveRecord::Migration[5.1]
  def change
    add_column :community_memberships, :can_post_requests, :boolean, default: false
    add_column :community_memberships, :can_send_dms, :boolean, default: false
  end
end
