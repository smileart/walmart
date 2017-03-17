# frozen_string_literal: true
require 'active_support/core_ext/object/deep_dup'
require 'nokogiri'
require 'sanitize'
require 'oj'

Oj.default_options = { :mode => :strict, :symbol_keys  => true }

require_relative './html_scraper'
require_relative './em_http_client'

#
class WalmartCrawlerInvalidUrl < StandardError; end

class WalmartCrawler
  WALMART_PRODUCT_ID_PATTERN = /\/(\d+)\z/

  WALMART_PRODUCT_STENCIL = {
    name: {
      selector: '[css] h1 div',
      callback: ->(name) {
        Sanitize.clean(name).strip
      }
    },
    price: {
      selector: '[css] .prod-BotRow .Price--stylized .Price-characteristic',
      callback: ->(price) {
        Float(price.scan(/content=\"(\d+\.?\d+?)\"/)[0][0])
      }
    }
  }.freeze

  PRODUCT_REQUEST = {
    'item' => {
      url: nil,
      method: :aget,
      data: {
        :head => {
          'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/602.1.28+ (KHTML, like Gecko) Version/9.0.3 Safari/601.4.4'
        },
        redirects: 100
      }
    }
  }.freeze

  PRODUCT_REVIEWS_BASE_URI = 'https://www.walmart.com/terra-firma/item/%s/reviews?showProduct=false&sort=relevancy&filters=&page=%s&limit=100'

  def initialize
    @http_client = EmHttpClient.new
    @html_scraper = HtmlScraper.new
  end

  def crawl(product_url)
    raise WalmartCrawlerInvalidUrl, product_url unless valid_url?(product_url.to_s)

    product_id = parse_id(product_url)

    product_request = PRODUCT_REQUEST.deep_dup
    product_request['item'][:url] = product_url.to_s

    response = @http_client.request(
      requests: product_request
    )

    return unless response['item'][:code] == 200

    html = Nokogiri::XML(response['item'][:body])
    @html_scraper.parse(html: html, stencils: WALMART_PRODUCT_STENCIL) do |product|
      product[:walmart_id] = product_id
      product[:reviews] = crawl_reviews(product_id)
      product
    end
  end

  def parse_id(url)
    url.to_s.scan(WALMART_PRODUCT_ID_PATTERN)[0][0]
  end

  private

  def valid_url?(url)
    begin
      uri = URI.parse(url.to_s)
    rescue URI::InvalidURIError
      return nil
    end

    return uri.to_s if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  end

  def crawl_reviews_page(product_id, page_number)
    reviews_page_url = PRODUCT_REVIEWS_BASE_URI.dup % [product_id, page_number]

    reviews_request = PRODUCT_REQUEST.deep_dup
    reviews_request['item'][:url] = reviews_page_url.to_s

    response = @http_client.request(
      requests: reviews_request
    )

    return unless response['item'][:code] == 200

    Oj.load(response['item'][:body])[:payload]
  end

  def crawl_reviews(product_id)
    first_reviews_page = crawl_reviews_page(product_id, 1)

    reviews = []
    reviews += first_reviews_page[:customerReviews]

    pages_count = first_reviews_page[:pagination][:pages].count

    return reviews unless pages_count > 1

    # first page already crawled here so start from the second one
    2.upto(pages_count) do |page_number|
      reviews_from_page = crawl_reviews_page(product_id, page_number)[:customerReviews]
      break if reviews_from_page.empty?
      reviews += reviews_from_page
    end

    reviews
  end
end

if $0 === __FILE__
end
