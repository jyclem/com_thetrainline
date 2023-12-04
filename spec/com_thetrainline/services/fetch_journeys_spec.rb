# frozen_string_literal: true

RSpec.describe ComThetrainline::Services::FetchJourneys do # rubocop:disable Metrics/BlockLength
  subject(:fetch_journeys_call) do
    described_class.new.call(from: from, to: to, departure_at: departure_at)
  end

  let(:from) { "Berlin" }
  let(:to) { "Munich" }
  let(:departure_at) { DateTime.new(2023, 12, 3, 15, 30) }
  let(:driver) { double("driver") }
  let(:element) { double("element") }

  before do
    stub_const("ComThetrainline::BASE_URL", "http://example.com")
    stub_const("ComThetrainline::Services::FetchJourneys::WEBSITE_URI", "/website_uri")

    allow(Selenium::WebDriver).to receive(:for).and_return(driver)
    allow(driver).to receive(:get)
    allow(driver).to receive(:find_element).and_return(element)
    allow(driver).to receive(:intercept)
    allow(driver).to receive(:quit)
    allow(element).to receive(:click)
    allow(element).to receive(:send_keys)
  end

  # we cannot really check the result so we are going to check that the main steps are done correctly

  it "goes to the correct URL" do
    fetch_journeys_call

    expect(driver).to have_received(:get).with("http://example.com/website_uri?outwardDate=2023-12-03T15:30")
  end

  it "clicks on the cookie acceptance button" do
    cookie_button = double("cookie_button")
    allow(cookie_button).to receive(:click)

    allow(driver).to receive(:find_element).with(id: "onetrust-accept-btn-handler").and_return(cookie_button)

    fetch_journeys_call

    expect(cookie_button).to have_received(:click)
  end

  it "fills the from-station input" do
    from_station_input = double("from_station_input")
    allow(from_station_input).to receive(:send_keys)

    allow(driver).to receive(:find_element).with(css: "input[data-test=from-station-input]")
                                           .and_return(from_station_input)

    fetch_journeys_call

    expect(from_station_input).to have_received(:send_keys).with("Berlin")
  end

  it "fills the to-station input" do
    to_station_input = double("to_station_input")
    allow(to_station_input).to receive(:send_keys)

    allow(driver).to receive(:find_element).with(css: "input[data-test=to-station-input]")
                                           .and_return(to_station_input)

    fetch_journeys_call

    expect(to_station_input).to have_received(:send_keys).with("Munich")
  end

  it "submits the form" do
    submit_button = double("submit_button")
    allow(submit_button).to receive(:click)

    allow(driver).to receive(:find_element).with(css: "button[data-test=submit-journey-search-button]")
                                           .and_return(submit_button)

    fetch_journeys_call

    expect(submit_button).to have_received(:click)
  end

  context "when the 'from' argument has not the correct type" do
    let(:from) { 1 }

    it "raises an error" do
      expect { fetch_journeys_call }.to raise_error(ComThetrainline::ArgumentTypeError, "from and to must be a String")
    end
  end

  context "when the 'to' argument has not the correct type" do
    let(:to) { 1 }

    it "raises an error" do
      expect { fetch_journeys_call }.to raise_error(ComThetrainline::ArgumentTypeError, "from and to must be a String")
    end
  end

  context "when the 'departure_at' argument has not the correct type" do
    let(:departure_at) { "" }

    it "raises an error" do
      expect { fetch_journeys_call }.to raise_error(
        ComThetrainline::ArgumentTypeError, "departure_at must be a DateTime"
      )
    end
  end
end
