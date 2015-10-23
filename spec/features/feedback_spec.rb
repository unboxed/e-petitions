require 'rails_helper'

RSpec.describe 'Feedback', type: :feature do
  let(:feedback) { Feedback.new(name: 'Joe Public', email: 'foo@example.com',
                 comment: "I can't submit a petition for some reason", petition_link_or_title: 'link') }
  let(:petitionemail) { 'petitionscommittee@parliament.uk' }
  before(:each) { visit feedback_url }
  
  it 'is submitted' do
    fill_in "feedback[email]", :with => feedback.email
    fill_in "feedback[petition_link_or_title]", :with => feedback.petition_link_or_title
    fill_in "feedback[comment]", :with => feedback.comment

    click_button("Send feedback")
    expect(page).to have_content("Thank")
    
    expect(unread_emails_for(petitionemail).size).to eq parse_email_count(1)
    open_email(petitionemail)
    expect(current_email).to have_body_text(/#{feedback.petition_link_or_title}/)
    expect(current_email).to have_body_text(/#{feedback.email}/)
    expect(current_email).to have_body_text(/#{feedback.comment}/)
  end
  
  it 'is checked for required fields' do
    click_button("Send feedback")
    expect(page).to have_content("must be completed")
    expect(unread_emails_for(petitionemail).size).to eq parse_email_count(0)
  end
end
      