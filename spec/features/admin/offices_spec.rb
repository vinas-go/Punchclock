require 'spec_helper'

feature "Offices", type: :feature, js: true do
  let(:admin_user) { FactoryBot.create(:super) }
  let(:office) { FactoryBot.create(:office) } 
  before do
    visit '/admin'
    
    fill_in 'admin_user_email', with: admin_user.email
    fill_in 'admin_user_password', with: admin_user.password
    click_button 'Entrar'
  end

  scenario 'index' do
     click_link 'Escritórios'
     expect(page).to have_content('Escritórios')
    		                                                      
     fill_in 'q_city', with: office.city
     click_button 'Filtrar'
     expect(page).to have_content(office.city)
    
     fill_in 'q_city', with: 'teste'
     click_button 'Filtrar'
     expect(page).to have_content('Nenhum(a) Escritórios encontrado(a)')
     
     click_link 'Escritórios'
     click_link 'Visualizar'  
     
     expect(page).to have_content('Detalhes do(a) Escritório')

     click_link 'Editar'
     
     expect(page).to have_content('Editar Escritório')
  end
  
  scenario 'new office' do
     click_link 'Escritórios'
     click_link 'Novo(a) Escritório'

     expect(page).to have_content('Novo(a) Escritório')
     
     click_button 'Criar Escritório'
     expect(page).to have_content('não pode ficar em branco')
  end
end
