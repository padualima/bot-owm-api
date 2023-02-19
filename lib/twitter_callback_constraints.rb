class TwitterCallbackConstraints
  def initialize; end

  def matches?(req)
    req.params[:provider].eql?('twitter2') && req.query_parameters.include?(:state) &&
      req.query_parameters.include?(:code)
  end
end
