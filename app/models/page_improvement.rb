class PageImprovement
  include ActiveModel::Validations

  validates_presence_of :description, :path

  def initialize(attributes)
    @path = attributes.fetch(:path, nil)
    @description = attributes.fetch(:description, nil)
    @name = attributes.fetch(:name, nil)
    @email = attributes.fetch(:email, nil)
  end

  def zendesk_ticket_attributes
    {
      'subject' => path,
      'comment' => {
        'body' => "[Details]\n#{description}\n\n[Name]\n#{name}\n\n[Email]\n#{email}\n\n[Path]\n#{path}"
      }
    }
  end

private
  attr_reader :description, :email, :name, :path
end
