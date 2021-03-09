class Profile < ApplicationRecord
  belongs_to :user

  validates :data, presence: true
  validates :user_id, uniqueness: true
  validates_with ProfileValidator

  has_many :custom_profile_fields, dependent: :destroy

  store_attribute :data, :custom_attributes, :json, default: {}

  SPECIAL_DISPLAY_ATTRIBUTES = %w[
    summary
    employment_title
    employer_name
    employer_url
    location
  ].freeze

  SPECIAL_SOCIAL_LINK_ATTRIBUTES = %w[
    twitter_url
    github_url
    facebook_url
    linkedin_url
    youtube_url
    instagram_url
    behance_url
    medium_url
    stackoverflow_url
    gitlab_url
    twitch_url
    mastodon_url
    website_url
    dribbble_url
  ].freeze

  # Generates typed accessors for all currently defined profile fields.
  def self.refresh_attributes!
    return if ENV["ENV_AVAILABLE"] == "false"
    return unless Database.table_exists?("profiles")

    ProfileField.find_each do |field|
      store_attribute :data, field.attribute_name.to_sym, field.type
    end
  end

  # Set up all profile attributes when this class loads so all store_attribute
  # accessors get defined immediately.
  refresh_attributes!

  # Returns an array of all currently defined `store_attribute`s on `data`.
  def self.attributes
    (stored_attributes[:data] || []).map(&:to_s)
  end

  def self.special_attributes
    SPECIAL_DISPLAY_ATTRIBUTES + SPECIAL_SOCIAL_LINK_ATTRIBUTES
  end

  def self.special_social_link_attributes
    SPECIAL_SOCIAL_LINK_ATTRIBUTES.freeze
  end

  def custom_profile_attributes
    custom_profile_fields.pluck(:attribute_name)
  end

  def clear!
    update(data: {})
  end
end
