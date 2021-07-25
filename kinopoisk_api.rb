require_relative './operations/films_operation'
require_relative './operations/reviews_operation'
require_relative './operations/staff_operation'
require 'faraday'
require 'faraday_middleware'

class Kinopoisk
  attr_reader :connect

  BASE_URL = 'https://kinopoiskapiunofficial.tech/'.freeze

  HEADERS = {
    'Content-Type' => 'application/json',
    'X-API-KEY' => 'b7c3b123-6325-45b2-8d02-d8f3ca9ee24c'
  }.freeze

  FILM_METHODS_WITH_OPERATIONS = {
    film: :by_id,
    film_frames: :frames,
    film_videos: :videos,
    film_studios: :studios,
    film_sequel_and_prequels: :sequel_and_prequels,
    films_search_by_keyword: :search_by_keyword,
    films_filters: :filters,
    films_search_by_filters: :search_by_filters,
    films_top: :top,
    films_similars: :similars,
    films_releases: :releases
  }.freeze

  REVIEW_METHODS_WITH_OPERATIONS = {
    reviews: :list_reviews,
    review_details: :review_details
  }.freeze

  STAFF_METHODS_WITH_OPERATIONS = {
    staff_by_id: :by_id,
    staff_by_film_id: :by_film_id
  }.freeze

  def initialize
    @connect = init_connect
  end

  def method_missing(meth, *args, &block)
    if FILM_METHODS_WITH_OPERATIONS[meth.to_sym]
      KinopoiskApi::FilmsOperation.call(
        operation: FILM_METHODS_WITH_OPERATIONS[meth.to_sym],
        data: args[0],
        connect: connect
      )
    elsif REVIEW_METHODS_WITH_OPERATIONS[meth.to_sym]
      KinopoiskApi::ReviewsOperation.call(
        operation: REVIEW_METHODS_WITH_OPERATIONS[meth.to_sym],
        data: args[0],
        connect: connect
      )
    elsif STAFF_METHODS_WITH_OPERATIONS[meth.to_sym]
      KinopoiskApi::StaffOperation.call(
        operation: STAFF_METHODS_WITH_OPERATIONS[meth.to_sym],
        data: args[0],
        connect: connect
      )
    end
  end

  def respond_to_missing?(method, include_private = false)
    methods.include?(method) || super
  end

  private

  def init_connect
    Faraday.new(url: BASE_URL, headers: HEADERS) do |f|
      f.response :raise_error
      f.response :follow_redirects
      f.response :json
      f.request :json
    end
  end
end

kp_obj = Kinopoisk.new
# pp kp_obj.films_top({ type: 'TOP_250_BEST_FILMS' })
# pp kp_obj.films_releases({ year: 2011, month: 'APRIL' })
# pp kp_obj.reviews({ filmId: 4231 })
# pp kp_obj.review_details({ reviewId: 75636 })
# pp kp_obj.staff_by_id({ filmId: 75636 })
# pp kp_obj.staff_by_film_id({ id: 75636 })
