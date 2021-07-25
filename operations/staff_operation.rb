module KinopoiskApi
  module StaffOperation
    extend self

    URL = 'api/v1/staff'.freeze

    STAFF_URLS = %i[
      by_id
      by_film_id
    ].freeze

    def call(operation:, data:, connect:)
      unless STAFF_URLS.include?(operation.to_sym)
        raise KinopoiskApi::Error.new(
          msg: 'Unknown operation',
          operation: operation
        )
      end

      return make_request(url: "#{URL}/#{data[:id]}", connect: connect) if data[:id]

      if data[:filmId].nil?
        raise KinopoiskApi::Error.new(
          msg: 'For staff needs filmId param',
          operation: operation
        )
      end

      make_request(url: URL, connect: connect, params: data)
    end

    private

    def make_request(url:, connect:, params: {})
      connect.get(url, params)
    rescue Faraday::ClientError, Faraday::ServerError => e
      puts "Response status - #{e.response[:status]}"
      puts e.response[:body]
    end
  end
end
