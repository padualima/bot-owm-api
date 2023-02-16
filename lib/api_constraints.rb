class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || (req.headers['Accept'] && req.headers['Accept'].include?(application_vendor))
  end

  private

  def application_vendor = "application/vnd.#{app_name}.v#{@version}"

  def app_name = Rails.application.class.module_parent_name.underscore.tr('_', '-')
end
