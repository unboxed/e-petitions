require 'rails_helper'

RSpec.describe TrendingIpsByPetitionJob, type: :job do
  let(:rate_limit) { double(RateLimit) }
  let(:current_time) { Time.utc(2019, 3, 31, 16, 0, 0) }
  let(:petition) { FactoryBot.create(:open_petition) }

  let(:geoip_db_path) { "/path/to/GeoLite2-Country.mmdb" }
  let(:geoip_db) { double(:geoip_db) }
  let(:geoip_result) { double(:geoip_result) }
  let(:geoip_country) { double(:geoip_country) }

  before do
    allow(MaxMindDB).to receive(:new).with(geoip_db_path).and_return(geoip_db)
    allow(geoip_db).to receive(:lookup).and_return(geoip_result)
    allow(geoip_result).to receive(:found?).and_return(true)
    allow(geoip_result).to receive(:country).and_return(geoip_country)
    allow(geoip_country).to receive(:iso_code).and_return("GB")

    allow(RateLimit).to receive(:first_or_create!).and_return(rate_limit)
    allow(rate_limit).to receive(:threshold_for_logging_trending_ip).and_return(1)
    allow(rate_limit).to receive(:threshold_for_notifying_trending_ip).and_return(2)

    FactoryBot.create(:validated_signature, petition: petition, ip_address: "192.168.1.1", validated_at: "2019-03-31T15:30:00Z")
    FactoryBot.create(:validated_signature, petition: petition, ip_address: "192.168.1.2", validated_at: "2019-03-31T15:35:00Z")
    FactoryBot.create(:validated_signature, petition: petition, ip_address: "192.168.1.2", validated_at: "2019-03-31T15:40:00Z")
  end

  context "when trending ip logging is disabled" do
    before do
      allow(rate_limit).to receive(:enable_logging_of_trending_ips?).and_return(false)
    end

    it "doesn't create any trending ip entries" do
      expect {
        described_class.perform_now(current_time)
      }.not_to change {
        TrendingIp.count
      }
    end
  end

  context "when trending ip logging is enabled" do
    before do
      allow(rate_limit).to receive(:enable_logging_of_trending_ips?).and_return(true)
    end

    it "creates trending ip entries" do
      expect {
        described_class.perform_now(current_time)
      }.to change {
        TrendingIp.count
      }.by(2)
    end

    it "enqueues a NotifyTrendingIpJob for ip addresses that are above the threshold" do
      expect {
        described_class.perform_now(current_time)
      }.to have_enqueued_job(NotifyTrendingIpJob)
    end
  end
end