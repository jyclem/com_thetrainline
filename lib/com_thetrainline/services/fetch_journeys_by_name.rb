# frozen_string_literal: true

require_relative "base"

require "selenium-webdriver"

module ComThetrainline
  module Services
    # FetchJourneysByName fetches the journeys from thetrailine.com
    #
    # Instead of going onto the welcome page of thetrainline.com and fill the form, we could also go directly
    # go to a dynamically made URL such as the following one and intercept the /api/journey-search/ request right away:
    # "https://www.thetrainline.com/book/results?journeySearchType=single&" \
    # "origin=urn%3Atrainline%3Ageneric%3Aloc%3A4916&" \
    # "destination=urn%3Atrainline%3Ageneric%3Aloc%3A827&" \
    # "outwardDate=2023-12-03T19%3A45%3A00&" \
    # "outwardDateType=departAfter&selectedTab=train&selectExactTime=true&splitSave=true&lang=fr&" \
    # However, in this case we need to know the code numbers of the origin and destination city (ex: 4920, 8276, ...)
    # which is less user friendly, that is why I chose the option to go through the form (but takes more time of course)
    class FetchJourneysByName < Base
      WEBSITE_URI = "/en-us"
      SEARCH_URI = "/api/journey-search/"

      def initialize
        @driver = Selenium::WebDriver.for(:chrome, options: web_driver_options)

        super
      end

      def call(from:, to:, departure_at:)
        raise ArgumentTypeError, "from and to must be a String" unless [from, to].all? { _1.is_a?(String) }
        raise ArgumentTypeError, "departure_at must be a DateTime" unless departure_at.is_a?(DateTime)

        @from = from
        @to = to
        @departure_at = departure_at
        @journey_search_response = nil

        fetch_journeys
      end

      private

      def web_driver_options
        Selenium::WebDriver::Options.chrome(
          args: [
            "--headless=new",
            "--start-maximized",
            "--disable-blink-features=AutomationControlled"
          ]
        )
      end

      def fetch_journeys
        go_to_website
        accept_cookies
        fill_form
        prepare_request_interception
        submit_form
        format_response
      ensure
        close
      end

      def go_to_website
        @driver.get("#{BASE_URL}#{WEBSITE_URI}?outwardDate=#{@departure_at.strftime("%Y-%m-%dT%H:%M")}")
      end

      def accept_cookies
        wait = Selenium::WebDriver::Wait.new(timeout: 10)
        wait.until { @driver.find_element(id: "onetrust-accept-btn-handler") }
        @driver.find_element(id: "onetrust-accept-btn-handler").click
      end

      def fill_form
        fill_form_station(@from, "from-station-input")
        fill_form_station(@to, "to-station-input")
      end

      def fill_form_station(keys, input)
        wait = Selenium::WebDriver::Wait.new(timeout: 3)

        @driver.find_element(css: "input[data-test=#{input}]").send_keys(keys)
        wait.until { @driver.find_element(css: "span[data-test=suggested-station-name]") }
        @driver.find_element(css: "span[data-test=suggested-station-name]").click # we click on the first result
      end

      def prepare_request_interception
        # we intercept the journey_search response
        @driver.intercept do |request, &continue|
          continue.call(request) do |response|
            if request.url == "#{BASE_URL}#{SEARCH_URI}"
              raise BlockedBySecurity, "Impossible to intercept the response" if response.code == 403

              @journey_search_response = response
            end
          end
        end
      end

      def submit_form
        # we submit the form
        @driver.find_element(css: "button[data-test=submit-journey-search-button]").click

        # we wait until getting the results
        wait = Selenium::WebDriver::Wait.new(timeout: 10)
        wait.until { @driver.find_element(css: "div[data-test=outward-eu-results-container]") }
      end

      def format_response
        return unless @journey_search_response

        # and finally we return the result formatted as a hash
        JSON.parse(@journey_search_response.body, symbolize_names: true)
      end

      def close
        @driver.quit
      end
    end
  end
end
