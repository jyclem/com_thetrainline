# frozen_string_literal: true

RSpec.describe ComThetrainline do # rubocop:disable Metrics/BlockLength
  let(:from) { double("from") }
  let(:to) { double("to") }
  let(:departure_at) { double("departure_at") }
  let(:journeys) { double("journeys") }
  let(:result) { double("result") }

  before do
    allow(ComThetrainline::Services::FormatResult).to receive(:call).and_return(result)
  end

  it "has a version number" do
    expect(ComThetrainline::VERSION).not_to be nil
  end

  shared_examples "fetch journeys" do |fetch_journeys_service|
    it "calls #{fetch_journeys_service} with the right parameters" do
      com_thetrainline_find

      expect(fetch_journeys_service).to have_received(:call).with(from: from, to: to, departure_at: departure_at)
    end
  end

  shared_examples "format result" do
    it "calls ComThetrainline::Services::FormatResult with the right parameters" do
      com_thetrainline_find

      expect(ComThetrainline::Services::FormatResult).to have_received(:call).with(search_result: journeys)
    end
  end

  shared_examples "return result" do
    it { is_expected.to eql(result) }
  end

  shared_examples "manage exceptions" do |fetch_journeys_service|
    context "when a known exception is raised" do
      before do
        allow(fetch_journeys_service).to receive(:call).and_raise(ComThetrainline::ArgumentTypeError)
      end

      it "prints a message" do
        expect { com_thetrainline_find }.to output(
          "ComThetrainline::ArgumentTypeError: ComThetrainline::ArgumentTypeError\n"
        ).to_stdout
      end
    end

    context "when an unknown exception is raised" do
      before do
        allow(fetch_journeys_service).to receive(:call).and_raise(StandardError)
      end

      it "prints a message" do
        expect { com_thetrainline_find }.to output(a_string_matching("Unknown Error")).to_stdout
      end
    end
  end

  describe "FetchJourneysByCode" do
    subject(:com_thetrainline_find) { described_class.find(from, to, departure_at) }

    before do
      allow(ComThetrainline::Services::FetchJourneysByCode).to receive(:call).and_return(journeys)
    end

    it_behaves_like "fetch journeys", ComThetrainline::Services::FetchJourneysByCode
    it_behaves_like "format result"
    it_behaves_like "return result"
    it_behaves_like "manage exceptions", ComThetrainline::Services::FetchJourneysByCode
  end

  describe "FetchJourneysByName" do
    subject(:com_thetrainline_find) { described_class.find_by_name(from, to, departure_at) }

    before do
      allow(ComThetrainline::Services::FetchJourneysByName).to receive(:call).and_return(journeys)
    end

    it_behaves_like "fetch journeys", ComThetrainline::Services::FetchJourneysByName
    it_behaves_like "format result"
    it_behaves_like "return result"
    it_behaves_like "manage exceptions", ComThetrainline::Services::FetchJourneysByName
  end
end
