module KinopoiskApi
  module ReviewsOperation
    extend self

    REVIEWS_URL = {
      list_reviews: 'api/v1/reviews',
      review_details: 'api/v1/reviews/details'
    }.freeze

    def call(operation:, data:, connect:)
      unless REVIEWS_URL[operation.to_sym]
        raise KinopoiskApi::Error.new(
          msg: 'Operation is not found',
          operation: operation
        )
      end

      if operation.to_sym == :review_details && !data[:reviewId]
        raise KinopoiskApi::Error.new(
          msg: 'For operation review_info need reviewId param',
          operation: operation
        )
      end

      make_request(url: REVIEWS_URL[operation.to_sym], params: data, connect: connect)
    end

    private

    def make_request(url:, connect:, params:)
      connect.get(url, params)
    rescue Faraday::ClientError, Faraday::ServerError => e
      puts "Response status - #{e.response[:status]}"
      puts e.response[:body]
    end
  end
end
