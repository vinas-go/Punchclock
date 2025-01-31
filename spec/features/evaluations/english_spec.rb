require 'rails_helper'

describe 'English Evaluation', type: :feature do
  let(:user)           { create_logged_in_user }
  let!(:office)        { create(:office, head: user) }
  let!(:evaluated)     { create(:user) }
  let!(:questionnaire) { create(:questionnaire, :kind_english, :with_questions, question_count: 2) }

  scenario 'User makes an evaluation revising his answers', js: true, aggregate_failures: true do
    visit evaluations_path

    find_link('', href: "/questionnaires_kinds?user_id=#{evaluated.id}").click
    click_on questionnaire.title, wait: 6

    find("label[for=evaluation_answers_attributes_0_response_#{questionnaire.questions.first.answer_options[1].downcase}]").click
    find("label[for=evaluation_answers_attributes_1_response_#{questionnaire.questions.last.answer_options[0].downcase}]").click
    fill_in 'Observação', with: 'Lots of Text'
    page.execute_script("$('#evaluation_evaluation_date').datepicker('setDate', '09/09/2021')")
    select '7', from: 'Pontuação'
    select 'fluent', from: 'Nível de Inglês'

    click_on 'Next'

    expect(page).to have_text(questionnaire.questions.first.answer_options[1]) &
                    have_text(questionnaire.questions.last.answer_options[0]) &
                    have_text('Lots of Text') &
                    have_text('7') &
                    have_text('fluent')

    click_on 'Edit'

    find("label[for=evaluation_answers_attributes_0_response_#{questionnaire.questions.first.answer_options[0].downcase}]").click
    find("label[for=evaluation_answers_attributes_1_response_#{questionnaire.questions.last.answer_options[1].downcase}]").click
    fill_in 'Observação', with: 'Lots, and lots, of Text'
    select '9', from: 'Pontuação'
    select 'advanced', from: 'Nível de Inglês'

    click_on 'Next'

    expect(page).to have_text(questionnaire.questions.first.answer_options[0]) &
                    have_text(questionnaire.questions.last.answer_options[1]) &
                    have_text('Lots, and lots, of Text') &
                    have_text('9') &
                    have_text('advanced')

    click_on 'Confirm'

    expect(page).to have_text 'Evaluation successfully saved!'
  end

  context 'when evaluation form has validations errors' do
    before do
      visit new_questionnaire_evaluation_path(questionnaire_id: questionnaire, evaluated_user_id: evaluated.id)
      click_on 'Next'
    end

    it 'shows error message' do
      expect(page).to have_text 'Check for any missing responses, please!'
    end
  end
end
