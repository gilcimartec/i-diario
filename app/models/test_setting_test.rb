class TestSettingTest < ActiveRecord::Base
  acts_as_copy_target

  audited associated_with: :test_setting

  belongs_to :test_setting

  has_enumeration_for :test_type, with: TestTypes

  validates :description, :weight, :test_type, presence: true
  validates :weight, numericality: true
end
