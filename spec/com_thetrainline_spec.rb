# frozen_string_literal: true

RSpec.describe ComThetrainline do # rubocop:disable Metrics/BlockLength
  subject(:com_thetrainline_find) { described_class.find("Paris", "Lille", departure_at) }

  let(:departure_at) { DateTime.new }
  let(:journeys) { double("journeys") }
  let(:result) { double("result") }

  before do
    allow(ComThetrainline::Services::FetchJourneys).to receive(:call).and_return(journeys)
    allow(ComThetrainline::Services::FormatResult).to receive(:call).and_return(result)
  end

  it { is_expected.to eql(result) }

  it "calls ComThetrainline::Services::FetchJourneys with the right parameters" do
    com_thetrainline_find

    expect(ComThetrainline::Services::FetchJourneys).to have_received(:call).with(
      from: "Paris", to: "Lille", departure_at: departure_at
    )
  end

  it "calls ComThetrainline::Services::FormatResult with the right parameters" do
    com_thetrainline_find

    expect(ComThetrainline::Services::FormatResult).to have_received(:call).with(search_result: journeys)
  end

  it "has a version number" do
    expect(ComThetrainline::VERSION).not_to be nil
  end

  context "when a known exception is raised" do
    before do
      allow(ComThetrainline::Services::FetchJourneys).to receive(:call).and_raise(ComThetrainline::ArgumentTypeError)
    end

    it "prints a message" do
      expect { com_thetrainline_find }.to output(
        "ComThetrainline::ArgumentTypeError: ComThetrainline::ArgumentTypeError\n"
      ).to_stdout
    end
  end

  context "when an unknown exception is raised" do
    before do
      allow(ComThetrainline::Services::FetchJourneys).to receive(:call).and_raise(StandardError)
    end

    it "prints a message" do
      expect { com_thetrainline_find }.to output(a_string_matching("Unknown Error")).to_stdout
    end
  end
end
