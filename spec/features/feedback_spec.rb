require 'rails_helper'

RSpec.describe 'Feedback', type: :feature do
  before(:each) { visit feedback_url }
  
  it 'Submit feedback' do
    @feedback = Feedback.new(:name => "Joe Public", :email => "foo@example.com",
      :comment => "I can't submit a petition for some reason", :petition_link_or_title => 'link')

    fill_in "feedback[email]", :with => @feedback.email
    fill_in "feedback[petition_link_or_title]", :with => @feedback.petition_link_or_title
    fill_in "feedback[comment]", :with => @feedback.comment

    click_button("Send feedback")
    expect(page).to have_content("Thank")
    
    expect(unread_emails_for('petitionscommittee@parliament.uk').size).to eq parse_email_count(1)
    open_email('petitionscommittee@parliament.uk')
    expect(current_email.default_part_body.to_s).to include(@feedback.petition_link_or_title)
    expect(current_email.default_part_body.to_s).to include(@feedback.email)
    expect(current_email.default_part_body.to_s).to include(@feedback.comment)
  end
  
  it 'Check required fields' do
    click_button("Send feedback")
    expect(page).to have_content("must be completed")
    expect(unread_emails_for('petitionscommittee@parliament.uk').size).to eq parse_email_count(0)
  end
end      