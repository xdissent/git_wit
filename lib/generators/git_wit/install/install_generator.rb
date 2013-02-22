class GitWit::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../../templates', __FILE__)

  argument :attributes, :type => :array, :default => [], :banner => "config[:value] config[:value]"

  def initialize(args, *options)
    super
    parse_attributes! if respond_to?(:attributes)
  end

  def copy_initializer
    template "git_wit.rb", "config/initializers/git_wit.rb"
  end

  def show_readme
    readme "README" if behavior == :invoke
  end

  def mount_route
    route 'mount GitWit::Engine => "/"'
  end

  protected
  def parse_attributes!
    attrs = (attributes || [])
    self.attributes = Hash[attrs.map { |attr| parse_attribute(attr) }.compact]
  end

  def parse_attribute(attr)
    k, v = attr.split(":", 2)
    v ||= true
    v = false if v == "false"
    [k.to_sym, v] if k.present?
  end

  def maybe_config(name, default)
    given = attributes.key?(name)
    value = given ? attributes[name] : default
    value = %("#{value}") if value.is_a? String
    value = ":#{value}" if value.is_a? Symbol
    pre = given ? "" : "# "
    "#{pre}config.#{name} = #{value}"
  end
end
