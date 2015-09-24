require 'rails_helper'

RSpec.describe 'Sponsor support notifications', type: :feature do
  let(:sponsor) {{ name: 'Anonymous Sponsor', email: generate(:sponsor_email) }}
  let(:petition_creator_email) { 'charlie.the.creator@example.com' }
  let(:threshold) { Site.threshold_for_moderation }

  let(:sponsor_petition_link) do
    petition_sponsor_url(sponsor_petition, token: sponsor_petition.sponsor_token)
  end

  let(:sponsor_petition) do
    create(:pending_petition,
            action: 'Charles to be nominated for sublimation',
            closed_at: 1.day.from_now,
            state: Petition::PENDING_STATE,
            creator_signature_attributes: { email: petition_creator_email})
  end

  before(:each) { stub_any_api_request.to_return(api_response(200, 'single')) }

  describe 'before reaching the threshold' do
    it 'emails the petition creator with sponsor support count' do
      visit sponsor_petition_link

      sponsors_petition_and_verifies_email_as sponsor
      signature = sponsor_petition.signatures.for_email(sponsor[:email]).first

      expect(signature).to be_present
      expect(signature).to be_sponsor

      signed_count = sponsor_petition.sponsors.where.not(signature_id: nil).count
      open_last_email_for petition_creator_email

      expect(current_email).to have_subject(/supported your petition/)
      expect(current_email).to have_body_text(/You have #{signed_count} supporter so far/)
    end
  end

  describe 'when it hits the threshold' do
    let(:threshold_less_one) { threshold - 1 }

    before(:each) do
      threshold_less_one.times do |idx|
        visit sponsor_petition_link

        sponsor = { name: "Anonymous Sponsor #{idx}", email: generate(:sponsor_email) }
        sponsors_petition_and_verifies_email_as sponsor
      end
    end

    it 'emails the petition creator that the sponsor threshold is met' do
      open_last_email_for petition_creator_email
      expect(current_email).to have_body_text(/You have #{threshold_less_one} supporters so far/)

      ActionMailer::Base.deliveries.clear

      visit sponsor_petition_link
      sponsors_petition_and_verifies_email_as sponsor

      expect(unread_emails_for(petition_creator_email).size).to eq 1
      expect_last_email_is_threshold_met_to_petition_creator(signed_count = threshold)
    end
  end

  describe 'when it is over the threshold' do
    before(:each) do
      threshold.times do |idx|
        visit sponsor_petition_link

        sponsor = { name: "Anonymous Sponsor #{idx}", email: generate(:sponsor_email) }
        sponsors_petition_and_verifies_email_as sponsor
      end

      ActionMailer::Base.deliveries.clear
    end

    it 'emails with threshold is met with updated sponsor count' do
      visit sponsor_petition_link
      sponsors_petition_and_verifies_email_as sponsor

      expect(unread_emails_for(petition_creator_email).size).to eq 1
      expect_last_email_is_threshold_met_to_petition_creator(signed_count = threshold+1)
    end
  end

  def sponsors_petition_and_verifies_email_as(sponsor = {})
    fill_in_signature_step_with sponsor
    click_on "Yes – this is my email address"

    open_email_for(sponsor[:email], subject: 'Please confirm your email address')
    click_first_link_in_email
  end

  def expect_last_email_is_threshold_met_to_petition_creator(signed_count)
    open_last_email_for petition_creator_email

    expect(current_email).to have_subject /We’re checking your petition/
    expect(current_email).to have_body_text(/#{signed_count} people have supported your petition so far/)
    expect(current_email).not_to have_body_text(/support from \d+ of your nominated sponsors/)
  end
end
