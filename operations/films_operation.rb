module KinopoiskApi
  module FilmsOperation
    extend self

    API_FILMS_URL = 'api/v2.1/films'.freeze
    API_NEW_FILMS_URL = 'api/v2.2/films'.freeze

    LIST_FILMS_URL = {
      search_by_keyword: { prefix_url: API_FILMS_URL, url: 'search-by-keyword' },
      filters: { prefix_url: API_FILMS_URL, url: 'filters' },
      search_by_filters: { prefix_url: API_FILMS_URL, url: 'search-by-filters' },
      top: { prefix_url: API_NEW_FILMS_URL, url: 'top' },
      releases: { prefix_url: API_FILMS_URL, url: 'releases' }
    }.freeze

    INFO_BY_FILM_URL = {
      frames: { prefix_url: API_FILMS_URL, url: 'frames' },
      videos: { prefix_url: API_NEW_FILMS_URL, url: 'videos' },
      similars: { prefix_url: API_NEW_FILMS_URL, url: 'similars' },
      studios: { prefix_url: API_FILMS_URL, url: 'studios' },
      sequel_and_prequels: { prefix_url: API_FILMS_URL, url: 'sequels_and_prequels' },
      by_id: { prefix_url: API_FILMS_URL, url: '' },
    }.freeze

    ANOTHER_REQUEST_LOGIC = %i[
      search_by_keyword
      filters
      list_top
    ].freeze

    def call(operation:, data:, connect:)
      url_data = LIST_FILMS_URL[operation.to_sym]

      return make_request(url: build_url_by_data(data: url_data), params: data, connect: connect) if url_data

      single_film = INFO_BY_FILM_URL[operation.to_sym]

      raise KinopoiskApi::Error.new(msg: 'Operation is not found', operation: operation) unless single_film
      raise KinopoiskApi::Error.new(msg: 'This operation needs for id', operation: operation) unless data[:id]

      url = build_url_by_data(data: single_film, id: data[:id])

      if ANOTHER_REQUEST_LOGIC.include?(operation.to_sym)
        return make_request_with_pages_count(url: url, params: data, connect: connect)
      end

      make_request(url: url, params: data, connect: connect)
    end

    private

    def build_url_by_data(data:, id: nil)
      return "#{data[:prefix_url]}/#{id}/#{data[:url]}" if id

      "#{data[:prefix_url]}/#{data[:url]}"
    end

    def make_request(url:, connect:, params:)
      connect.get(url, params)
    rescue Faraday::ClientError, Faraday::ServerError => e
      puts "Response status - #{e.response[:status]}"
      puts e.response[:body]
    end
  end
end
