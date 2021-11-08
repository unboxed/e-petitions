class EmailPrivacyPolicyUpdatesJob < ApplicationJob
  queue_as :high_priority

  def perform
    Petition.not_anonymized.moderated.find_each do |petition|
      EmailPrivacyPolicyUpdateJob.perform_later(petition)
    end
  end
end
