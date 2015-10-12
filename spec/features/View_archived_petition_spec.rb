require 'rails_helper'

RSpec.describe 'View archived petition', type: :feature do
  
  it 'view an archived petition' do
    @petition = FactoryGirl.create(:archived_petition, :closed, title: 'Spend more money on Defence')
    visit archived_petition_url(@petition)
    expect(page).to have_content(@petition.title)
    expect(page).to have_content(@petition.description)
    expect(page).to have_title('Spend more money on Defence'.to_s)
    expect(page).to have_css("li.meta-deadline", :text => "Deadline " + @petition.closed_at.strftime("%e %B %Y").squish)
    expect(page).to have_content('This petition has been archived It was submitted during the 2010–2015 Conservative – Liberal Democrat coalition government')
  end
  
  it 'go to old URL' do
    @petition = FactoryGirl.create(:archived_petition, :closed, title: 'Spend more money on Defence')
    visit petition_url(@petition)
    expect(current_path).to eq(archived_petition_path(@petition))
    expect(page).to have_content(@petition.title)
    expect(page).to have_content(@petition.description)
    expect(page).to have_title('Spend more money on Defence'.to_s)
    expect(page).to have_css("li.meta-deadline", :text => "Deadline " + @petition.closed_at.strftime("%e %B %Y").squish)
    expect(page).to have_content('This petition has been archived It was submitted during the 2010–2015 Conservative – Liberal Democrat coalition government')
  end 
end