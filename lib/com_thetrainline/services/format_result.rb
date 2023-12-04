# frozen_string_literal: true

require_relative "base"

module ComThetrainline
  module Services
    # FetchJourneys fetches the journes from thetrailine.com
    class FormatResult < Base
      FARE_TYPE_COMFORT_MAPPING = {
        "urn:trainline:sncf:fare:25ee315b0ac945adce4b429e19396c94" => 1,
        "urn:trainline:sncf:fare:56d92abf88e6201bf1cd8def58047753" => 2,
        "urn:trainline:sncf:fare:e182f7e04f64f0f4a4ac475a42b2ea9d" => 3
      }.freeze

      def call(search_result:)
        raise ArgumentTypeError, "search_result must be a Hash" unless search_result.is_a?(Hash)

        @search_result = search_result

        results
      end

      private

      def results
        journeys.map { |_, journey| format_journey(journey) }
      end

      def format_journey(journey)
        departure_at = DateTime.parse(journey[:departAt])
        arrival_at = DateTime.parse(journey[:arriveAt])

        journey_result(
          station_name(journey[:legs].first, :departureLocation), departure_at,
          station_name(journey[:legs].last, :arrivalLocation), arrival_at,
          service_agencies(journey), changeovers(journey), products(journey), fares(journey)
        )
      end

      # rubocop:disable Metrics/ParameterLists
      def journey_result(
        departure_station, departure_at, arrival_station, arrival_at, service_agencies, changeovers, products, fares
      )
        {
          departure_station: departure_station, departure_at: departure_at,
          arrival_station: arrival_station, arrival_at: arrival_at,
          service_agencies: service_agencies,
          duration_in_minutes: ((arrival_at - departure_at) * 24 * 60).to_i,
          changeovers: changeovers,
          products: products,
          fares: fares
        }
      end
      # rubocop:enable Metrics/ParameterLists

      def station_name(leg_id, attribute)
        location_id = find_item_by_id(journey_search, :legs, leg_id)&.fetch(attribute)
        find_item_by_id(data, :locations, location_id)&.fetch(:name) if location_id
      end

      def service_agencies(journey)
        journey[:legs].map do |leg_id|
          carrier_id = find_item_by_id(journey_search, :legs, leg_id)&.fetch(:carrier)
          find_item_by_id(data, :carriers, carrier_id)&.fetch(:name)
        end
      end

      def changeovers(journey)
        journey[:legs].size - 1
      end

      def products(journey)
        journey[:legs].map do |leg_id|
          transport_mode_id = find_item_by_id(journey_search, :legs, leg_id)&.fetch(:transportMode)
          find_item_by_id(data, :transportModes, transport_mode_id)&.fetch(:name)
        end
      end

      def fares(journey)
        journey[:sections]&.flat_map do |section_id|
          alternatives = find_item_by_id(journey_search, :sections, section_id)&.fetch(:alternatives)
          alternatives&.flat_map do |alternative_id|
            alternative = find_item_by_id(journey_search, :alternatives, alternative_id)
            alternative_to_fare(alternative)
          end
        end
      end

      def alternative_to_fare(alternative)
        amount = alternative.dig(:fullPrice, :amount)
        price_in_cents = amount && (amount * 100)
        currency = alternative.dig(:fullPrice, :currencyCode)

        alternative[:fares]&.map do |fare_id|
          fare = find_item_by_id(journey_search, :fares, fare_id)
          fare_type = find_item_by_id(data, :fareTypes, fare[:fareType])

          format_fare(price_in_cents, currency, fare_type)
        end
      end

      def format_fare(price_in_cents, currency, fare_type)
        {
          name: fare_type[:name],
          price_in_cents: price_in_cents,
          currency: currency,
          comfort_class: FARE_TYPE_COMFORT_MAPPING[fare_type[:code]]
        }
      end

      def find_item_by_id(source, item_type, id)
        source.dig(item_type, id.to_sym)
      end

      def data
        @search_result[:data]
      end

      def journey_search
        @journey_search ||= @search_result.dig(:data, :journeySearch)
      end

      def journeys
        @journeys ||= @search_result.dig(:data, :journeySearch, :journeys) || []
      end
    end
  end
end
