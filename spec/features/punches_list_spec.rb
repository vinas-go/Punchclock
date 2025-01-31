# frozen_string_literal: true

require 'rails_helper'

feature 'Punches list' do
  let!(:authed_user) { create_logged_in_user }
  let!(:punch) {
    create(:punch, user_id: authed_user.id)
  }
  let!(:other_punch) {
    create(:punch, user_id: authed_user.id)
  }
  let!(:punch_with_attachment) {
    create(:punch, :with_attachment , user_id: authed_user.id)
  }

  before do
    visit '/punches'
    expect(page).to have_selector('a[href="/punches/new"]') &
                    have_selector('table') &
                    have_content('TOTAL:')
  end

  scenario 'follow show link' do
    click_link "shw-#{punch.id}"

    expect(page).to have_content(I18n.localize(punch.from, format: '%d/%m/%Y')) &
                    have_content(I18n.localize(punch.from, format: '%H:%M')) &
                    have_content(I18n.localize(punch.to, format: '%H:%M')) &
                    have_content(punch.project.name) &
                    have_content(authed_user.name)
  end

  scenario 'follow edit link' do
    click_link "edt-#{punch.id}"
    expect(page).to have_content I18n.t(
      :editing, scope: %i(helpers actions), model: Punch.model_name.human
    )
  end

  scenario 'follow destroy link' do
    click_link "dlt-#{punch.id}"
    expect(page).to have_content('Punch foi deletado com sucesso.')
  end

  scenario 'filter punches' do
    fill_in 'punches_filter_form_since', with: I18n.localize(other_punch.from, format: '%d/%m/%Y')
    fill_in 'punches_filter_form_until', with: I18n.localize(other_punch.to + 1.day, format: '%d/%m/%Y')
    select other_punch.project.name, from: 'punches_filter_form_project_id'
    click_button 'Filtrar'

    expect(page).to have_css('tbody tr', count: 1)
  end

  it "Renders attachment link" do
    expect(page).to have_link('', href: punch_with_attachment.attachment_url)  
  end

  scenario 'follow attachment link' do
    find("a[href='#{punch_with_attachment.attachment_url}']").click
    expect(page).to have_content('This is a punch attachment')
  end
end
