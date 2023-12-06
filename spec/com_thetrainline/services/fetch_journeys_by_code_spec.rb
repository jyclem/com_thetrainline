# frozen_string_literal: true

RSpec.describe ComThetrainline::Services::FetchJourneysByCode do # rubocop:disable Metrics/BlockLength
  subject(:fetch_journeys_call) do
    described_class.new.call(from: from, to: to, departure_at: departure_at)
  end

  let(:from) { "3358" }
  let(:to) { "5097" }
  let(:departure_at) { DateTime.new(2023, 12, 3, 15, 30) }
  let(:response) { double("response", body: "{\"json\":\"result\"}") }

  before do
    allow(Net::HTTP).to receive(:post).and_return(response) # we could also use "webmock" here
  end

  it { is_expected.to eql(json: "result") }

  context "when the JSON post raises an exception" do
    let(:exception) { SocketError.new("any error") }

    before do
      allow(Net::HTTP).to receive(:post).and_raise(exception)
    end

    it "forwards the exception" do
      expect { fetch_journeys_call }.to raise_error(exception)
    end
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
