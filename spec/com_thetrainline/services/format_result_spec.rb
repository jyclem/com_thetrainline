# frozen_string_literal: true

RSpec.describe ComThetrainline::Services::FormatResult do # rubocop:disable Metrics/BlockLength
  subject(:format_result_call) { described_class.new.call(search_result: search_result) }

  let(:search_result) do
    JSON.parse(File.read("lib/com_thetrainline/examples/journey-search-result.json"), symbolize_names: true)
  end

  it "returns the expected result" do # rubocop:disable Metrics/BlockLength
    expect(format_result_call).to eql(
      [{ arrival_at: DateTime.parse("2023-12-16T10:46:00+01:00 ((2460295j,35160s,0n),+3600s,2299161j)"),
         arrival_station: "Marseille St-Charles",
         changeovers: 0,
         departure_at: DateTime.parse("2023-12-16T05:58:00+01:00 ((2460295j,17880s,0n),+3600s,2299161j)"),
         departure_station: "Lille-Europe",
         duration_in_minutes: 288,
         fares: [{ comfort_class: 1,
                   currency: "EUR",
                   name: "SECONDE",
                   price_in_cents: 9700 },
                 { comfort_class: 2,
                   currency: "EUR",
                   name: "PREMIERE",
                   price_in_cents: 10_300 },
                 { comfort_class: 3,
                   currency: "EUR",
                   name: "BUSINESS PREMIERE",
                   price_in_cents: 20_400 }],
         products: ["Train"],
         service_agencies: ["SNCF"] },
       { arrival_at: DateTime.parse("2023-12-16T12:24:00+01:00 ((2460295j,41040s,0n),+3600s,2299161j)"),
         arrival_station: "Marseille St-Charles",
         changeovers: 0,
         departure_at: DateTime.parse("2023-12-16T07:24:00+01:00 ((2460295j,23040s,0n),+3600s,2299161j)"),
         departure_station: "Lille-Europe",
         duration_in_minutes: 300,
         fares: [{ comfort_class: 1,
                   currency: "EUR",
                   name: "SECONDE",
                   price_in_cents: 9700 },
                 { comfort_class: 2,
                   currency: "EUR",
                   name: "PREMIERE",
                   price_in_cents: 10_300 }],
         products: ["Train"],
         service_agencies: ["SNCF"] },
       { arrival_at: DateTime.parse("2023-12-16T12:24:00+01:00 ((2460295j,41040s,0n),+3600s,2299161j)"),
         arrival_station: "Marseille St-Charles",
         changeovers: 0,
         departure_at: DateTime.parse("2023-12-16T07:24:00+01:00 ((2460295j,23040s,0n),+3600s,2299161j)"),
         departure_station: "Lille-Europe",
         duration_in_minutes: 300,
         fares: [{ comfort_class: 3,
                   currency: "EUR",
                   name: "BUSINESS PREMIERE",
                   price_in_cents: 20_400 }],
         products: ["Train"],
         service_agencies: ["SNCF"] },
       { arrival_at: DateTime.parse("2023-12-16T13:14:00+01:00 ((2460295j,44040s,0n),+3600s,2299161j)"),
         arrival_station: "Marseille St-Charles",
         changeovers: 1,
         departure_at: DateTime.parse("2023-12-16T08:12:00+01:00 ((2460295j,25920s,0n),+3600s,2299161j)"),
         departure_station: "Lille-Flandres",
         duration_in_minutes: 302,
         fares: [{ comfort_class: 1,
                   currency: "EUR",
                   name: "SECONDE",
                   price_in_cents: 11_600 },
                 { comfort_class: 2,
                   currency: "EUR",
                   name: "PREMIERE",
                   price_in_cents: 20_200 },
                 { comfort_class: 3,
                   currency: "EUR",
                   name: "BUSINESS PREMIERE",
                   price_in_cents: 26_200 }],
         products: %w[Train Train],
         service_agencies: %w[SNCF SNCF] }]
    )
  end

  context "when the 'search_result' argument has not the correct type" do
    let(:search_result) { "" }

    it "raises an error" do
      expect { format_result_call }.to raise_error(
        ComThetrainline::ArgumentTypeError, "search_result must be a Hash"
      )
    end
  end
end
