module PetitionJourneyHelper
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
    fill_in 'Name', with: detail[:name] || 'Ben'
    fill_in 'Email', with: detail[:email]
    check 'I am a British citizen or UK resident' unless detail[:nocheck]

    fill_in 'Postcode', with: detail[:postcode] || 'E1 6PL'
    select detail[:location] || 'United Kingdom', from: 'Location'

    click_button 'Continue'
  end

  def fill_in_all_petition_stages_with(detail = {})
    fill_in_start_petition_step_with(detail)
    click_button 'This looks good'
    fill_in_signature_step_with(detail)
  end
end
