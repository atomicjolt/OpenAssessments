class Account < ActiveRecord::Base
  include Lti::Methods

  validates :domain, uniqueness: true
  validates :code, uniqueness: true
  validates :code, presence: true
  validates :lti_secret, uniqueness: true
  
  before_save :clean_domain

  has_many :users
  has_many :assessments
  has_many :assessment_settings
  has_many :lti_credentials

  def clean_domain
    self.domain = "http://#{self.domain}" unless self.domain.include?("http://") || self.domain.include?("https://")
    self.domain = URI.parse(self.domain).host
  end

  def self.main
    Account.find_by(code: Rails.application.secrets.application_code)
  end

  def default_settings
    self.assessment_settings.any? ? self.assessment_settings.first : nil
  end

end
