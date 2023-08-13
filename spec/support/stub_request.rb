# frozen_string_literal: true

class StubRequest
  include WebMock

  private_class_method :new

  def initialize(url:, method:, path: '', request: {}, response: {})
    @url = url
    @method = method
    @path = path
    @request = request
    @response = response

    configure_webmock
  end

  def self.get(options = {})
    new(method: :get, **options).send(:call!)
  end

  def self.post(options = {})
    new(method: :post, **options).send(:call!)
  end

  private

  def configure_webmock
    disable_net_connect!(allow_localhost: true)
  end

  def call!
    @url = "#{@url}/#{@path}" if @path.present?

    stub_request(@method, @url).tap do |stub|
      stub.with(@request) if @request.present?
      stub.to_return(@response)
    end
  end
end
