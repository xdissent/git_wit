class PublicKey < ActiveRecord::Base
  belongs_to :user
  attr_accessible :raw_content
  attr_writer :raw_content

  validate :check_raw_content
  validates :content, uniqueness: true

  before_validation :save_raw_content

  EXTRACT_CONTENT = /^(ssh-(?:dss|rsa)\s.*?)(?:\s+(.*)\s*)?$/

  def raw_content
    return @raw_content if @raw_content.present?
    "#{content} #{comment}" if content.present? && comment.present?
  end

  def split_raw_content
    @raw_content.scan(EXTRACT_CONTENT).flatten.map(&:to_s)
  end

  def save_raw_content
    self.content, self.comment = split_raw_content if @raw_content.present?
  end

  def check_raw_content
    if !@raw_content.present? && !content.present?
      errors.add :raw_content, :blank
    elsif @raw_content.present? && split_raw_content.first.blank?
      errors.add :raw_content, "cannot be parsed"
    end
  end
end
