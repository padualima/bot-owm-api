class TwitterCallbackConstraints
  def initialize; end

  def matches?(req)
    req.query_parameters.include?(:state) && req.query_parameters.include?(:code)
  end
end
