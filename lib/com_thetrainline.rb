# frozen_string_literal: true

require_relative "com_thetrainline/version"
require_relative "com_thetrainline/base_url"
require_relative "com_thetrainline/services/fetch_journeys"
require_relative "com_thetrainline/services/format_result"

require "date" # for the DateTime type

# ComThetrainline is the entry of the Gem
module ComThetrainline
  module_function

  def find(from, to, departure_at = DateTime.now)
    search_result = Services::FetchJourneys.call(from: from, to: to, departure_at: departure_at)

    Services::FormatResult.call(search_result: search_result)
  rescue ArgumentTypeError, BlockedBySecurity => e
    puts "#{e.class}: #{e.message}"
  rescue StandardError => e
    puts "Unknown Error: #{e.full_message} #{e.backtrace.first(10)}"
  end

  # from = "Lille", to = "Marseille St-Charles", departure_at = DateTime.new(2023, 12, 16, 6, 0)
  def find_example
    search_result = JSON.parse(
      File.read("lib/com_thetrainline/examples/journey-search-result.json"), symbolize_names: true
    )

    Services::FormatResult.call(search_result: search_result)
  rescue ArgumentTypeError => e
    puts "Argument Format Error: #{e.message}"
  rescue StandardError => e
    puts "Unknown Error: #{e.full_message} #{e.backtrace.first(10)}"
  end

  class Error < StandardError; end
  class ArgumentTypeError < StandardError; end
  class BlockedBySecurity < StandardError; end
end
