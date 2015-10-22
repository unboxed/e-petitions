require 'rails_helper'

RSpec.describe 'View archived petition', type: :feature do
  let(:archive_message) {'This petition has been archived It was submitted during the 2010–2015 Conservative – Liberal Democrat coalition government'}
  let(:petition) {FactoryGirl.create(:archived_petition, :closed, title: 'Spend more money on Defence')}
  let(:rejected_petition) {FactoryGirl.create(:archived_petition, :rejected, title: "Please bring back Eldorado", reason_for_rejection: "<i>We<i> like http://www.google.com and bambi@gmail.com")}
  
  it 'that is closed' do
    visit archived_petition_url(petition)
    expect(page).to have_content(petition.title)
    expect(page).to have_content(petition.description)
    expect(page).to have_title('Spend more money on Defence')
    expect(page).to have_css("li.meta-deadline", :text => "Deadline " + petition.closed_at.strftime("%e %B %Y").squish)
    expect(page).to have_content(archive_message)
  end
  
  it 'via the old URL' do
    visit petition_url(petition)
    expect(current_path).to eq(archived_petition_path(petition))
    expect(page).to have_content(petition.title)
    expect(page).to have_content(petition.description)
    expect(page).to have_title('Spend more money on Defence')
    expect(page).to have_css("li.meta-deadline", :text => "Deadline " + petition.closed_at.strftime("%e %B %Y").squish)
    expect(page).to have_content(archive_message)
  end
  
  it 'that contains urls, email addresses and html tags' do
    FactoryGirl.create(:archived_petition, :closed, title: 'Spend more money on Defence', description: "<i>We<i> like http://www.google.com and bambi@gmail.com")
    visit archived_petition_url(ArchivedPetition.find_by(title: 'Spend more money on Defence'))
    expect(page).to have_content("<i>We<i>")
    expect(page).to have_link("http://www.google.com", href: "http://www.google.com")
    expect(page).to have_link("bambi@gmail.com", href: "mailto:bambi@gmail.com")
  end  

  it 'that is rejected with a reason' do
    visit archived_petition_url(rejected_petition)
    expect(page).to have_content(rejected_petition.title)
    expect(page).to have_content(rejected_petition.description)
    expect(page).to have_title('Please bring back Eldorado')
    expect(page).to have_content(rejected_petition.reason_for_rejection)
    expect(page).to have_content("<i>We<i>")
    expect(page).to have_link("http://www.google.com", href: "http://www.google.com")
    expect(page).to have_link("bambi@gmail.com", href: "mailto:bambi@gmail.com")
    expect(page).to_not have_content("0 signatures")
    expect(page).to_not have_content('Deadline')
    expect(page).not_to have_css("a", :text => "Sign")
  end
  
  it 'and not be able to sign it' do
    visit archived_petition_url(petition)
    expect(current_path).to eq(archived_petition_path(petition))
    expect(page).to have_content(petition.title)
    expect(page).to have_content(petition.description)
    expect(page).to have_title('Spend more money on Defence')
    expect(page).not_to have_css("a", :text => "Sign")
  end
  
  it 'and see the closed message' do
    visit archived_petition_url(petition)
    expect(page).to have_content(archive_message)
  end
end
