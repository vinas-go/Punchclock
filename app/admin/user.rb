ActiveAdmin.register User do
  permit_params :name, :email, :company_id, :role, :reviewer_id, :hour_cost, :password, :active,
    :allow_overtime, :office_id

  scope :active, default: true
  scope :inactive
  scope :all

  index do
    column :company if current_admin_user.is_super?
    column :name
    column :email
    column :office
    column :role
    column :hour_cost do |user|
      number_to_currency user.hour_cost
    end
    column :allow_overtime
    column :active
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :email
      row :office
      row :role
      row :reviewer
      row :hour_cost
      row :allow_overtime
      row :active
      row :last_sign_in_at
      row :created_at
      row :updated_at
    end
  end

  filter :name
  filter :email
  filter :company, if: proc { current_admin_user.is_super? }

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :hour_cost, input_html: { value: '0.0' }
      f.input :office
      if current_admin_user.is_super?
        f.input :company
      else
        f.input :company, collection: {
          user.company.name => current_admin_user.company_id
        }
      end
      f.input :role, as: :select, collection: User.roles.keys
      f.input :reviewer
      f.input :allow_overtime
      f.input :password
      f.input :active
    end
    f.actions
  end

  controller do
    def scoped_collection
      super.includes :company, :reviewer
    end

    def new
      @user = User.new
      @user.company_id = current_company.id unless signed_in_as_super?
      new!
    end

    def create
      create! do |success, failure|
        success.html do
          NotificationMailer.notify_user_registration(@user).deliver
          redirect_to resource_path
        end
      end
    end

    def update
      params[:user].delete("password") if params[:user][:password].blank?
      super
    end

    def signed_in_as_super?
      current_admin_user.is_super?
    end

    def current_company
      current_admin_user.company
    end
  end
end
