require 'rails_helper'

RSpec.describe 'Creating Petition', type: :feature do
  before(:each) { visit home_url }

  describe 'with search' do
    let!(:petition) { create(:open_petition, :with_additional_details, :action => "Rioters lose benefits") }
    let(:search_query) { 'Rioters should lose benefits' }

    it 'fills in the petition title with the search query' do
      click_start_petition

      expect(page.current_url).to eq check_petitions_url
      expect(page).to have_content("What do you want us to do?")
      expect(page).to have_css("form textarea[name=q]")

      fill_in_search_query_with search_query

      expect(page).to have_content(petition.action)

      click_link_or_button "My petition is different"

      expect(page.current_url).to eq "#{new_petition_url}?petition_action=#{search_query.split(' ').join('+')}"
      expect(page).to have_field("What do you want us to do?", "#{petition.action}")
    end

    it "doesn't parse the xss attack when searching for petitions" do
      click_start_petition
      fill_in_search_query_with "'onmouseover='alert(1)'"

      expect(sanitize_page(page)).to be_valid_markup
    end
  end

  it 'creates a pending petition with a pending signature and email' do
    petition = {
                 action: 'The wombats of wimbledon rock.',
                 background: 'Give half of Wimbledon rock to wombats!',
                 name: 'Womboid Wibbledon',
                 email: 'womboid@wimbledon.com',
                 postcode: 'SW14 9RQ',
                 location: 'United Kingdom',
                 additional_detail: 'The racial tensions between the wombles and the wombats are heating up.
                   Racial attacks are a regular occurrence and the death count is already in 5 figures.
                   The only resolution to this crisis is to give half of Wimbledon common to the Wombats and
                   to recognise them as their own independent state.'
               }

    # TODO: Move to better place
    stub_request(:get, "http://data.parliament.uk/membersdataplatform/services/mnis/Constituencies/SW149RQ/").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.1'}).
      to_return(:status => 200, :body => "", :headers => {})

    visit new_petition_url

    expect(page).to have_title 'Start a petition - Petitions'
    expect(page.current_url).to match(%r!^https://!)

    fill_in_all_petition_stages_with petition

    expect(sanitize_page(page)).to be_valid_markup
    expect(page).to have_content 'Make sure this is right'
    expect(page).to have_field 'Email'

    click_button 'Yes – this is my email address'
    expect(page).to have_text 'One more step…'

    last_petition = Petition.last
    expect(last_petition.action).to eq 'The wombats of wimbledon rock.'
    expect(last_petition.state).to eq 'pending'

    signature = Signature.where(email: petition[:email]).find_by(name: petition[:name], state: 'pending')
    expect(signature).not_to be_nil
    expect(signature.notify_by_email?).to be_truthy

    # TODO: Get emails and assert
    # on it look at the cuke definitions a little more
    # open_last_email_for

    # email = ActionMailer::Base.deliveries.last
    # expect(email.to).to eq petition[:email]
    # expect(email.subject).to eq 'Action required: Petition'
    # expect(email.body).to match(/\/petitions\/\\d+\/sponsors\/[A-Za-z0-9]+/)
  end

  def click_start_petition
     within 'main#content' do
      click_link 'Start a petition'
    end
  end

  def fill_in_search_query_with(search_query)
    fill_in 'What do you want us to do?', with: search_query
    click_button 'Continue'
  end

  def fill_in_start_petition_step_with(detail = {})
    fill_in 'What do you want us to do?', with: detail[:action]
    fill_in 'Background', with: detail[:background]
    fill_in 'Additional details', with: detail[:additional_detail]

    click_button 'Preview petition'
  end

  def fill_in_signature_step_with(detail = {})
    fill_in 'Name', with: detail[:name]
    fill_in 'Email', with: detail[:email]
    check 'I am a British citizen or UK resident'

    fill_in 'Postcode', with: detail[:postcode]
    select detail[:location], from: 'Location'

    click_button 'Continue'
  end

  def fill_in_all_petition_stages_with(detail = {})
    fill_in_start_petition_step_with(detail)
    click_button 'This looks good'
    fill_in_signature_step_with(detail)
  end
end
