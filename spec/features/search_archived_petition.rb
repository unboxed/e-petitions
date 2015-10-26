require 'rails_helper'

RSpec.describe 'Search archived petitions', type: :feature do
  
  before :each do
    FactoryGirl.create(:archived_petition, :closed, title: 'Wombles are great', signature_count: '835', opened_at: '2012-01-01', closed_at: '2013-01-01')
    FactoryGirl.create(:archived_petition, :closed, title: 'The Wombles of Wimbledon', signature_count: '243', opened_at: '2011-04-01', closed_at: '2013-01-01')
    FactoryGirl.create(:archived_petition, :closed, title: 'Common People', signature_count: '639', opened_at: '2014-10-01', closed_at: '2013-01-01')
    FactoryGirl.create(:archived_petition, :rejected, title: "Eavis vs the Wombles", reason_for_rejection: "<i>We<i> like http://www.google.com and bambi@gmail.com")
  end  
  
  it 'shows an ordered list' do
    visit "/archived/petitions"
    fill_in "search", with: "Wombles"
    click_button("Search")
    expect(page.current_url).to eq "https://petition.parliament.uk/archived/petitions?utf8=%E2%9C%93&q=Wombles"
    
    expect(page).to have_content('Eavis vs the Wombles Rejected')
    expect(page).to have_content('The Wombles of Wimbledon 243 signatures')
    expect(page).to have_content('Wombles are great 835 signatures')
    
    expect(sanitize_page(page)).to be_valid_markup
  end
  
  it 'paginates correctly' do
    
  end
end  
    