Given(/^a moderator user exists with email: "([^"]*)", first_name: "([^"]*)", last_name: "([^"]*)"$/) do |email, first_name, last_name|
  @user = FactoryBot.create(:moderator_user, first_name: first_name, last_name: last_name, email: email)
end

Given(/^a moderator user exists with email: "([^"]*)", first_name: "([^"]*)", last_name: "([^"]*)", current_sign_in_at: "([^"]*)"$/) do |email, first_name, last_name, current_sign_in_at|
  @user = FactoryBot.create(:moderator_user, first_name: first_name, last_name: last_name, email: email, current_sign_in_at: current_sign_in_at)
end

Given(/^(\d+) moderator users exist$/) do |number|
  number.times do |count|
    FactoryBot.create(:moderator_user)
  end
end

Given(/^(\d+) petitions exist with state: "([^"]*)"$/) do |number, state|
  number.times do |count|
    FactoryBot.create(:petition, state: state)
  end
end

Given(/^an open petition exists with action: "([^"]*)"(?:, signature_count: (\d+))?$/) do |action, signature_count|
  @petition = FactoryBot.create(:open_petition, action: action, validated_signatures: signature_count)
end

Given(/^a rejected petition exists with action: "([^"]*)"$/) do |action|
  @petition = FactoryBot.create(:rejected_petition, action: action)
end

Given(/^a hidden petition exists with action: "([^"]*)"$/) do |action|
  @petition = FactoryBot.create(:hidden_petition, action: action)
end

Given(/^a sponsored petition exists with action: "([^"]*)"$/) do |action|
  @petition = FactoryBot.create(:sponsored_petition, action: action)
end

Then(/^a petition should exist with action: "([^"]*)", state: "([^"]*)"$/) do |action, state|
  expect(Petition.where(action: action, state: state)).to exist
end

Given(/^a tag exists with name: "([^"]*)"$/) do |name|
  @tag = FactoryBot.create(:tag, name: name)
end

Given(/^an sponsored petition exists with action: "([^"]*)"$/) do |action|
  @petition = FactoryBot.create(:sponsored_petition, action: action)
end

Given(/^an open petition exists with action: "([^"]*)", background: "([^"]*)"(?:, signature_count: (\d+))?$/) do |action, background, signature_count|
  @petition = FactoryBot.create(:open_petition, action: action, background: background, validated_signatures: signature_count)
end

Given('a closed petition exists with action: {string}') do |action|
  @petition = FactoryBot.create(:closed_petition, action: action)
end

Given('a closed petition exists with action: {string}, closed_at: {timestamp}') do |action, closed_at|
  @petition = FactoryBot.create(:closed_petition, action: action, closed_at: closed_at)
end

Given(/^a pending petition exists with action: "([^"]*)"$/) do |action|
  @petition = FactoryBot.create(:pending_petition, action: action)
end

Given(/^a validated petition exists with action: "([^"]*)"$/) do |action|
  @petition = FactoryBot.create(:validated_petition, action: action)
end

Given('an open petition exists with action: {string}, additional_details: {string}, closed_at: {timestamp}, signature_count: {int}') do |action, additional_details, closed_at, signature_count|
  @petition = FactoryBot.create(:open_petition, action: action, additional_details: additional_details, closed_at: closed_at, validated_signatures: signature_count)
end

Given('an open petition exists with action: {string}, background: {string}, closed_at: {timestamp}, signature_count: {int}') do |action, background, closed_at, signature_count|
  @petition = FactoryBot.create(:open_petition, action: action, background: background, closed_at: closed_at, validated_signatures: signature_count)
end

Given('an open petition exists with action: {string}, closed_at: {timestamp}, signature_count: {int}') do |action, closed_at, signature_count|
  @petition = FactoryBot.create(:open_petition, action: action, closed_at: closed_at, validated_signatures: signature_count)
end

Then(/^a signature should exist with email: "([^"]*)", state: "([^"]*)"$/) do |email, state|
  expect(Signature.where(email: email, state: state)).to exist
end

Then(/^a signature should exist with email: "([^"]*)", state: "([^"]*)", location_code: "([^"]*)", postcode: "([^"]*)"$/) do |email, state, location_code, postcode|
  expect(Signature.where(email: email, state: state, location_code: location_code, postcode: postcode)).to exist
end

Then(/^a petition should not exist with action: "([^"]*)", state: "([^"]*)"$/) do |action, state|
  expect(Petition.where(action: action, state: state)).not_to exist
end

Then(/^a signature should not exist with email: "([^"]*)", state: "([^"]*)"$/) do |email, state|
  expect(Signature.where(email: email, state: state)).not_to exist
end

Given(/^(\d+) open petitions exist with action: "([^"]*)"$/) do |number, action|
  number.times do |count|
    FactoryBot.create(:open_petition, action: action)
  end
end

Given(/^an open petition exists with action: "([^"]*)", additional_details: "([^"]*)"(?:, signature_count: (\d+))?$/) do |action, additional_details, signature_count|
  @petition = FactoryBot.create(:open_petition, action: action, additional_details: additional_details, validated_signatures: signature_count)
end

Given(/^an open petition exists with action: "([^"]*)", committee_note: "([^"]*)"(?:, signature_count: (\d+))?$/) do |action, committee_note, signature_count|
  @petition = FactoryBot.create(:open_petition, action: action, committee_note: committee_note, validated_signatures: signature_count)
end

Given(/^the following archived petitions exist:$/) do |table|
  parliament = FactoryBot.create(:parliament, :coalition)

  table.raw[1..-1].each do |petition|
    attributes = {
      parliament:      parliament,
      action:          petition[0],
      state:           petition[1],
      signature_count: petition[2],
      opened_at:       petition[3],
      closed_at:       petition[4],
      created_at:      petition[5]
    }

    FactoryBot.create(:archived_petition, attributes)
  end
end

Given(/^the following petitions exist:$/) do |table|
  table.raw[1..-1].each do |petition|
    attributes = {
      action:          petition[0],
      signature_count: petition[2],
      open_at:         petition[3]
    }

    FactoryBot.create(:"#{petition[1]}_petition", attributes)
  end
end

Given(/^(\d+) archived petitions exist with action: "([^"]*)"$/) do |number, action|
  number.times { FactoryBot.create(:archived_petition, action: action) }
end

Given(/^an archived petition "([^"]*)" exists$/) do |action|
  FactoryBot.create(:archived_petition, action: action)
end

Given(/^an archived petition exists with action: "([^"]*)", background: "([^"]*)"$/) do |action, background|
  FactoryBot.create(:archived_petition, action: action, background: background)
end

Given(/^an archived petition exists with action: "([^"]*)", committee_note: "([^"]*)"$/) do |action, committee_note|
  FactoryBot.create(:archived_petition, action: action, committee_note: committee_note)
end

Then(/^a feedback should not exist with comment: "([^"]*)"$/) do |comment|
  expect(Feedback.where(comment: comment)).not_to exist
end
