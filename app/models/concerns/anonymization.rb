module Anonymization
  extend ActiveSupport::Concern

  included do
    class_attribute :anonymization_job, instance_writer: false

    if self == Archived::Petition
      self.anonymization_job = Archived::AnonymizePetitionJob
    else
      self.anonymization_job = AnonymizePetitionJob
    end
  end

  module ClassMethods
    def anonymize_petitions!(time = Time.current)
      in_need_of_anonymizing(time).find_each do |petition|
        petition.anonymize!
      end
    end

    def in_need_of_anonymizing(time = Time.current)
      time_limit = 6.months.ago(time)

      where(anonymized_at: nil).and(
        rejected_in_need_of_anonymizing(time_limit).or(
          closed_in_need_of_anonymizing(time_limit)
        )
      )
    end

    def closed_in_need_of_anonymizing(time_limit)
      where(state: self::CLOSED_STATE)
        .where(arel_table[:closed_at].lt(time_limit))
    end

    def rejected_in_need_of_anonymizing(time_limit)
      where(state: self::REJECTED_STATES)
        .where(arel_table[:rejected_at].lt(time_limit))
    end
  end

  def anonymize!(time = Time.current)
    anonymization_job.perform_later(self, time.iso8601)
  end

  def anonymized?
    anonymized_at?
  end
end

