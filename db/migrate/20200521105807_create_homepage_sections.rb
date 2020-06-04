class CreateHomepageSections < ActiveRecord::Migration[5.1]
  def change
    create_table :homepage_sections do |t|
      t.string :local_business_sec_heading
      t.string :local_business_sec_col1_heading
      t.string :local_business_sec_col2_heading
      t.string :local_business_sec_col3_heading
      t.string :local_business_sec_col4_heading
      t.string :local_business_sec_col5_heading
      t.string :local_business_sec_col6_heading
      t.attachment :local_business_sec_col1_image
      t.attachment :local_business_sec_col2_image
      t.attachment :local_business_sec_col3_image
      t.attachment :local_business_sec_col4_image
      t.attachment :local_business_sec_col5_image
      t.attachment :local_business_sec_col6_image
      t.string :local_business_sec_col1_explore_btn_text
      t.string :local_business_sec_col2_explore_btn_text
      t.string :local_business_sec_col3_explore_btn_text
      t.string :local_business_sec_col4_explore_btn_text
      t.string :local_business_sec_col5_explore_btn_text
      t.string :local_business_sec_col6_explore_btn_text
      t.string :local_business_sec_col1_explore_btn_link
      t.string :local_business_sec_col2_explore_btn_link
      t.string :local_business_sec_col3_explore_btn_link
      t.string :local_business_sec_col4_explore_btn_link
      t.string :local_business_sec_col5_explore_btn_link
      t.string :local_business_sec_col6_explore_btn_link
      t.text :local_business_sec_col1_explore_btn_content
      t.text :local_business_sec_col2_explore_btn_content
      t.text :local_business_sec_col3_explore_btn_content
      t.text :local_business_sec_col4_explore_btn_content
      t.text :local_business_sec_col5_explore_btn_content
      t.text :local_business_sec_col6_explore_btn_content

      t.string :explore_service_heading_title
      t.string :explore_service_heading_link
      t.attachment :explore_service_col1_icon
      t.attachment :explore_service_col2_icon
      t.attachment :explore_service_col3_icon
      t.attachment :explore_service_col4_icon
      t.attachment :explore_service_col5_icon
      t.attachment :explore_service_col6_icon
      t.string :explore_service_col1_heading
      t.string :explore_service_col2_heading
      t.string :explore_service_col3_heading
      t.string :explore_service_col4_heading
      t.string :explore_service_col5_heading
      t.string :explore_service_col6_heading
      t.text :explore_service_col1_content
      t.text :explore_service_col2_content
      t.text :explore_service_col3_content
      t.text :explore_service_col4_content
      t.text :explore_service_col5_content
      t.text :explore_service_col6_content

      t.string :discover_community_heading
      t.text :discover_community_description
      t.string :discover_community_button_text
      t.string :discover_community_button_link
      t.attachment :discover_community_right_image

      t.string :how_it_work_heading
      t.string :how_it_work_col1_heading
      t.string :how_it_work_col2_heading
      t.string :how_it_work_col3_heading
      t.text :how_it_work_col1_content
      t.text :how_it_work_col2_content
      t.text :how_it_work_col3_content
      t.string :how_it_work_button_text
      t.string :how_it_work_button_link
      t.attachment :how_it_work_right_image

      t.string :advantage_heading
      t.string :advantage_col1_heading
      t.string :advantage_col2_heading
      t.string :advantage_col3_heading
      t.text :advantage_col1_content
      t.text :advantage_col2_content
      t.text :advantage_col3_content
      t.attachment :advantage_col1_image
      t.attachment :advantage_col2_image
      t.attachment :advantage_col3_image

      t.timestamps
    end
  end
end
