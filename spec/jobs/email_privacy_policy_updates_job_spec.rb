require "rails_helper"

RSpec.describe EmailPrivacyPolicyUpdatesJob, type: :job do
  Petition::MODERATED_STATES.each do |state|
    context "#{state} petition" do
      let!(:petition) { FactoryBot.create("#{state}_petition") }

      it "enqueues job" do
        expect {
          described_class.perform_now
        }.to change {
          enqueued_jobs.count
        }.by(1)
      end
    end

    context "#{state} anonymized petition" do
      let!(:petition) do
        FactoryBot.create(
          "#{state}_petition".to_sym,
          anonymized_at: DateTime.current
        )
      end

      it "does not enqueue job" do
        expect {
          described_class.perform_now
        }.not_to change {
          enqueued_jobs.count
        }
      end
    end
  end

  (Petition::STATES - Petition::MODERATED_STATES).each do |state|
    context "#{state} petition" do
      let!(:petition) { FactoryBot.create("#{state}_petition") }

      it "does not enqueue job" do
        expect {
          described_class.perform_now
        }.not_to change {
          enqueued_jobs.count
        }
      end
    end
  end
end
