# frozen_string_literal: true

require_relative "base"

module ComThetrainline
  module Services
    # FetchJourneysByCode fetches the journeys from thetrailine.com
    class FetchJourneysByCode < Base
      SEARCH_URI = "/api/journey-search/"

      JOURNEY_DATE = {
        type: "departAfter", time: nil
      }.freeze
      TRANSIT_DEFINITION = {
        direction: "outward",
        origin: nil,
        destination: nil,
        journeyDate: JOURNEY_DATE
      }.freeze
      BODY = {
        cards: [],
        type: "single",
        maximumJourneys: 5,
        transportModes: ["mixed"],
        composition: %w[through interchangeSplit],
        requestedCurrencyCode: "EUR",
        isEurope: true,
        includeRealtime: true,
        directSearch: false,
        transitDefinitions: [TRANSIT_DEFINITION]
      }.freeze

      def call(from:, to:, departure_at:)
        raise ArgumentTypeError, "from and to must be a String" unless [from, to].all? { _1.is_a?(String) }
        raise ArgumentTypeError, "departure_at must be a DateTime" unless departure_at.is_a?(DateTime)

        @from = from
        @to = to
        @departure_at = departure_at

        response_body_parsed
      end

      private

      def response_body_parsed
        JSON.parse(fetch_journeys_response.body, symbolize_names: true)
      end

      def fetch_journeys_response
        Net::HTTP.post(URI("#{BASE_URL}/#{SEARCH_URI}"), body.to_json, { Accept: "application/json" })
      end

      def body
        BODY.merge(
          transitDefinitions: [
            TRANSIT_DEFINITION.merge(
              origin: "urn:trainline:generic:loc:#{@from}",
              destination: "urn:trainline:generic:loc:#{@to}",
              journeyDate: JOURNEY_DATE.merge(time: @departure_at.iso8601)
            )
          ]
        )
      end
    end
  end
end
