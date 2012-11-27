module Instagram
  # Defines HTTP request methods
  module Request
    attr_accessor :requests_limit, :remaining_requests
    
    # Perform an HTTP GET request
    def get(path, options={}, raw=false, unformatted=false)
      request(:get, path, options, raw, unformatted)
    end

    # Perform an HTTP POST request
    def post(path, options={}, raw=false, unformatted=false)
      request(:post, path, options, raw, unformatted)
    end

    # Perform an HTTP PUT request
    def put(path, options={}, raw=false, unformatted=false)
      request(:put, path, options, raw, unformatted)
    end

    # Perform an HTTP DELETE request
    def delete(path, options={}, raw=false, unformatted=false)
      request(:delete, path, options, raw, unformatted)
    end

    private

    def set_request_limit_values(response)
      @requests_limit = response.headers["x-ratelimit-limit"]
      @remaining_requests = response.headers["x-ratelimit-remaining"]
    end

    # Perform an HTTP request
    def request(method, path, options, raw=false, unformatted=false)
      response = connection(raw).send(method) do |request|
        path = formatted_path(path) unless unformatted
        case method
        when :get, :delete
          request.url(path, options)
        when :post, :put
          request.path = path
          request.body = options unless options.empty?
        end
      end
      set_request_limit_values(response)
      raw ? response : response.body
    end

    def formatted_path(path)
      [path, format].compact.join('.')
    end
  end
end
