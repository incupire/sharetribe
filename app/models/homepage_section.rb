# == Schema Information
#
# Table name: homepage_sections
#
#  id                                          :integer          not null, primary key
#  local_business_sec_heading                  :string(255)
#  local_business_sec_col1_heading             :string(255)
#  local_business_sec_col2_heading             :string(255)
#  local_business_sec_col3_heading             :string(255)
#  local_business_sec_col4_heading             :string(255)
#  local_business_sec_col5_heading             :string(255)
#  local_business_sec_col6_heading             :string(255)
#  local_business_sec_col1_image_file_name     :string(255)
#  local_business_sec_col1_image_content_type  :string(255)
#  local_business_sec_col1_image_file_size     :integer
#  local_business_sec_col1_image_updated_at    :datetime
#  local_business_sec_col2_image_file_name     :string(255)
#  local_business_sec_col2_image_content_type  :string(255)
#  local_business_sec_col2_image_file_size     :integer
#  local_business_sec_col2_image_updated_at    :datetime
#  local_business_sec_col3_image_file_name     :string(255)
#  local_business_sec_col3_image_content_type  :string(255)
#  local_business_sec_col3_image_file_size     :integer
#  local_business_sec_col3_image_updated_at    :datetime
#  local_business_sec_col4_image_file_name     :string(255)
#  local_business_sec_col4_image_content_type  :string(255)
#  local_business_sec_col4_image_file_size     :integer
#  local_business_sec_col4_image_updated_at    :datetime
#  local_business_sec_col5_image_file_name     :string(255)
#  local_business_sec_col5_image_content_type  :string(255)
#  local_business_sec_col5_image_file_size     :integer
#  local_business_sec_col5_image_updated_at    :datetime
#  local_business_sec_col6_image_file_name     :string(255)
#  local_business_sec_col6_image_content_type  :string(255)
#  local_business_sec_col6_image_file_size     :integer
#  local_business_sec_col6_image_updated_at    :datetime
#  local_business_sec_col1_explore_btn_text    :string(255)
#  local_business_sec_col2_explore_btn_text    :string(255)
#  local_business_sec_col3_explore_btn_text    :string(255)
#  local_business_sec_col4_explore_btn_text    :string(255)
#  local_business_sec_col5_explore_btn_text    :string(255)
#  local_business_sec_col6_explore_btn_text    :string(255)
#  local_business_sec_col1_explore_btn_link    :string(255)
#  local_business_sec_col2_explore_btn_link    :string(255)
#  local_business_sec_col3_explore_btn_link    :string(255)
#  local_business_sec_col4_explore_btn_link    :string(255)
#  local_business_sec_col5_explore_btn_link    :string(255)
#  local_business_sec_col6_explore_btn_link    :string(255)
#  local_business_sec_col1_explore_btn_content :text(65535)
#  local_business_sec_col2_explore_btn_content :text(65535)
#  local_business_sec_col3_explore_btn_content :text(65535)
#  local_business_sec_col4_explore_btn_content :text(65535)
#  local_business_sec_col5_explore_btn_content :text(65535)
#  local_business_sec_col6_explore_btn_content :text(65535)
#  explore_service_heading_title               :string(255)
#  explore_service_heading_link                :string(255)
#  explore_service_col1_icon_file_name         :string(255)
#  explore_service_col1_icon_content_type      :string(255)
#  explore_service_col1_icon_file_size         :integer
#  explore_service_col1_icon_updated_at        :datetime
#  explore_service_col2_icon_file_name         :string(255)
#  explore_service_col2_icon_content_type      :string(255)
#  explore_service_col2_icon_file_size         :integer
#  explore_service_col2_icon_updated_at        :datetime
#  explore_service_col3_icon_file_name         :string(255)
#  explore_service_col3_icon_content_type      :string(255)
#  explore_service_col3_icon_file_size         :integer
#  explore_service_col3_icon_updated_at        :datetime
#  explore_service_col4_icon_file_name         :string(255)
#  explore_service_col4_icon_content_type      :string(255)
#  explore_service_col4_icon_file_size         :integer
#  explore_service_col4_icon_updated_at        :datetime
#  explore_service_col5_icon_file_name         :string(255)
#  explore_service_col5_icon_content_type      :string(255)
#  explore_service_col5_icon_file_size         :integer
#  explore_service_col5_icon_updated_at        :datetime
#  explore_service_col6_icon_file_name         :string(255)
#  explore_service_col6_icon_content_type      :string(255)
#  explore_service_col6_icon_file_size         :integer
#  explore_service_col6_icon_updated_at        :datetime
#  explore_service_col1_heading                :string(255)
#  explore_service_col2_heading                :string(255)
#  explore_service_col3_heading                :string(255)
#  explore_service_col4_heading                :string(255)
#  explore_service_col5_heading                :string(255)
#  explore_service_col6_heading                :string(255)
#  explore_service_col1_content                :text(65535)
#  explore_service_col2_content                :text(65535)
#  explore_service_col3_content                :text(65535)
#  explore_service_col4_content                :text(65535)
#  explore_service_col5_content                :text(65535)
#  explore_service_col6_content                :text(65535)
#  discover_community_heading                  :string(255)
#  discover_community_description              :text(65535)
#  discover_community_button_text              :string(255)
#  discover_community_button_link              :string(255)
#  discover_community_right_image_file_name    :string(255)
#  discover_community_right_image_content_type :string(255)
#  discover_community_right_image_file_size    :integer
#  discover_community_right_image_updated_at   :datetime
#  how_it_work_heading                         :string(255)
#  how_it_work_col1_heading                    :string(255)
#  how_it_work_col2_heading                    :string(255)
#  how_it_work_col3_heading                    :string(255)
#  how_it_work_col1_content                    :text(65535)
#  how_it_work_col2_content                    :text(65535)
#  how_it_work_col3_content                    :text(65535)
#  how_it_work_button_text                     :string(255)
#  how_it_work_button_link                     :string(255)
#  how_it_work_right_image_file_name           :string(255)
#  how_it_work_right_image_content_type        :string(255)
#  how_it_work_right_image_file_size           :integer
#  how_it_work_right_image_updated_at          :datetime
#  advantage_heading                           :string(255)
#  advantage_col1_heading                      :string(255)
#  advantage_col2_heading                      :string(255)
#  advantage_col3_heading                      :string(255)
#  advantage_col1_content                      :text(65535)
#  advantage_col2_content                      :text(65535)
#  advantage_col3_content                      :text(65535)
#  advantage_col1_image_file_name              :string(255)
#  advantage_col1_image_content_type           :string(255)
#  advantage_col1_image_file_size              :integer
#  advantage_col1_image_updated_at             :datetime
#  advantage_col2_image_file_name              :string(255)
#  advantage_col2_image_content_type           :string(255)
#  advantage_col2_image_file_size              :integer
#  advantage_col2_image_updated_at             :datetime
#  advantage_col3_image_file_name              :string(255)
#  advantage_col3_image_content_type           :string(255)
#  advantage_col3_image_file_size              :integer
#  advantage_col3_image_updated_at             :datetime
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#  testimonial_col1_image_file_name            :string(255)
#  testimonial_col1_image_content_type         :string(255)
#  testimonial_col1_image_file_size            :integer
#  testimonial_col1_image_updated_at           :datetime
#  testimonial_col2_image_file_name            :string(255)
#  testimonial_col2_image_content_type         :string(255)
#  testimonial_col2_image_file_size            :integer
#  testimonial_col2_image_updated_at           :datetime
#  testimonial_col3_image_file_name            :string(255)
#  testimonial_col3_image_content_type         :string(255)
#  testimonial_col3_image_file_size            :integer
#  testimonial_col3_image_updated_at           :datetime
#  testimonial_column1_content                 :text(65535)
#  testimonial_column1_star_count              :float(24)
#  testimonial_column2_name                    :text(65535)
#  testimonial_column2_work                    :text(65535)
#  testimonial_column2_type                    :text(65535)
#  testimonial_column2_content                 :text(65535)
#  testimonial_column2_star_count              :float(24)
#  testimonial_column3_name                    :text(65535)
#  testimonial_column3_work                    :text(65535)
#  testimonial_column3_type                    :text(65535)
#  testimonial_column3_content                 :text(65535)
#  testimonial_column3_star_count              :float(24)
#  testimonial_main_heading                    :string(255)
#  testimonial_column1_name                    :string(255)
#  testimonial_column1_work                    :string(255)
#  testimonial_column1_type                    :string(255)
#  testimonial_column1_link                    :text(65535)
#  testimonial_column2_link                    :text(65535)
#  testimonial_column3_link                    :text(65535)
#

class HomepageSection < ApplicationRecord
  has_many :homepage_columns

  has_attached_file :local_business_sec_col1_image,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}
  has_attached_file :local_business_sec_col2_image,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}
  has_attached_file :local_business_sec_col3_image,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}
  has_attached_file :local_business_sec_col4_image,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}
  has_attached_file :local_business_sec_col5_image,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}
  has_attached_file :local_business_sec_col6_image,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}



  has_attached_file :explore_service_col1_icon,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}
  has_attached_file :explore_service_col2_icon,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}
  has_attached_file :explore_service_col3_icon,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}
  has_attached_file :explore_service_col4_icon,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}
  has_attached_file :explore_service_col5_icon,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}
  has_attached_file :explore_service_col6_icon,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}


  has_attached_file :discover_community_right_image,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      medium: "320x220#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}
  has_attached_file :how_it_work_right_image,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      medium: "320x220#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}





  has_attached_file :advantage_col1_image,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      medium: "320x220#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}

  has_attached_file :advantage_col2_image,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      medium: "320x220#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}

  has_attached_file :advantage_col3_image,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      medium: "320x220#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}

  has_attached_file :testimonial_col1_image,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      medium: "320x220#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}

  has_attached_file :testimonial_col2_image,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      medium: "320x220#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}

  has_attached_file :testimonial_col3_image,
    :styles => {
      min: "60x60#",
      thumb: "120x120#",
      medium: "320x220#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>"}

  validates_attachment_content_type :local_business_sec_col1_image, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :local_business_sec_col2_image, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :local_business_sec_col3_image, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :local_business_sec_col4_image, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :local_business_sec_col5_image, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :local_business_sec_col6_image, content_type: /\Aimage\/.*\z/
  
  validates_attachment_content_type :explore_service_col1_icon, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :explore_service_col2_icon, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :explore_service_col3_icon, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :explore_service_col4_icon, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :explore_service_col5_icon, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :explore_service_col6_icon, content_type: /\Aimage\/.*\z/


  validates_attachment_content_type :discover_community_right_image, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :how_it_work_right_image, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :advantage_col1_image, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :advantage_col2_image, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :advantage_col3_image, content_type: /\Aimage\/.*\z/

  validates_attachment_content_type :testimonial_col1_image, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :testimonial_col2_image, content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :testimonial_col3_image, content_type: /\Aimage\/.*\z/

end
