# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminsSpreadsheet do
  let(:user) { create(:user).decorate }
  let(:admins_spreadsheet) { AdminsSpreadsheet.new([user]) }
  let(:header_attributes) do
    %w[
      id
      email
      last_sign_in_at
      last_sign_in_ip
      name
      confirmed_at
      active
      allow_overtime
      occupation
      observation
      specialty
      github
      contract_type
      role
      started_at
      created_at
      updated_at
    ].map { |attribute| User.human_attribute_name(attribute) }
  end
  let (:date_attributes) do
    [
      user.last_sign_in_at, user.confirmed_at, user.created_at,
      user.updated_at, user.started_at
    ].map { |attr| attr.nil? ? nil : I18n.l(attr, format: :long) }
  end
  let (:body_attributes) do
    [
      user.id,
      user.email,
      user.last_sign_in_ip,
      user.name,
      user.active,
      user.allow_overtime,
      user.occupation,
      user.observation,
      user.specialty,
      user.github,
      user.contract_type,
      user.role
    ].concat(date_attributes)
  end

  describe '#to_string_io' do
    subject do
      admins_spreadsheet
        .to_string_io
        .force_encoding('iso-8859-1')
        .encode('utf-8')
    end

    it 'returns spreadsheet data' do
      is_expected.to include(user.email,
                             user.name,
                             user.occupation,
                             user.specialty,
                             user.github,
                             user.contract_type,
                             user.role)
    end

    it 'returns spreadsheet with header' do
      is_expected.to include(User.human_attribute_name('email'),
                             User.human_attribute_name('name'),
                             User.human_attribute_name('specialty'),
                             User.human_attribute_name('github'),
                             User.human_attribute_name('contract_type'),
                             User.human_attribute_name('role'))
    end
  end

  describe '#generate_xls' do
    subject(:spreadsheet) { admins_spreadsheet.generate_xls }

    it 'returns spreadsheet object with header' do
      expect(spreadsheet.row(0)).to containing_exactly(*header_attributes)
    end

    it 'returns spreadsheet object with body' do
      expect(spreadsheet.row(1)).to containing_exactly(*body_attributes)
    end
  end

  describe '#body' do
    subject { admins_spreadsheet.body(user) }

    it 'return body data' do
      is_expected.to containing_exactly(*body_attributes)
    end
  end

  describe '#header' do
    subject { admins_spreadsheet.header }

    it 'returns header data' do
      is_expected.to containing_exactly(*header_attributes)
    end
  end
end
