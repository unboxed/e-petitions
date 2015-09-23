require 'rails_helper'

RSpec.describe 'Create Petition', type: :feature do
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

  describe 'with valid detail' do
    let(:petition) do
      {
        action: 'The wombats of wimbledon rock.',
        background: 'Give half of Wimbledon rock to wombats!',
        name: 'Womboid Wibbledon',
        email: 'womboid@wimbledon.com',
        postcode: '',
        location: 'United Kingdom',
        additional_detail: 'The racial tensions between the wombles and the wombats are heating up.
               Racial attacks are a regular occurrence and the death count is already in 5 figures.
               The only resolution to this crisis is to give half of Wimbledon common to the Wombats
               and to recognise them as their own independent state.'
      }
    end

    before(:each) do
      stub_any_api_request.to_return(api_response(200, 'single'))
      ActionMailer::Base.deliveries.clear
    end

    [{postcode: 'E1 6PL', type: :valid}, {postcode: 'AA11 1AA', type: :invalid}].each do |data|
      it "creates a pending petition with signature when the postcode is #{data[:type]}" do
        petition.merge!(postcode: data[:postcode])

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

        expect(ActionMailer::Base.deliveries.size).to eq 1

        open_email_for(petition[:email], subject: 'Action required: Petition')
        current_email.to have_body(/\/petitions\/\\d+\/sponsors\/[A-Za-z0-9]+/)
      end
    end
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
