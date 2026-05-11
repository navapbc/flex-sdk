# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Audit logs', type: :request do
  let(:user)       { User.create!(first_name: 'Test',  last_name: 'User') }
  let(:other_user) { User.create!(first_name: 'Other', last_name: 'User') }

  before do
    # Mock current_user for the dummy app since it doesn't have Devise
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(AuditLogsController).to receive(:current_user).and_return(user)
    # rubocop:enable RSpec/AnyInstance
  end

  describe 'GET /audit_logs' do
    it 'renders successfully' do
      get '/staff/audit_logs'
      expect(response).to have_http_status(:ok)
    end

    it 'shows the empty-state message when no audit lines exist' do
      get '/staff/audit_logs'
      expect(response.body).to include('No audit logs recorded yet.')
    end

    context 'when audit lines exist' do
      before do
        own_form   = create(:test_application_form, user_id: user.id)
        other_form = create(:test_application_form, user_id: other_user.id)

        create(:strata_audit_line, subject: own_form,   action: 'form.created.visible')
        create(:strata_audit_line, subject: other_form, action: 'form.created.hidden')
        create(:strata_audit_line, subject: nil,        action: 'system.event.visible')
      end

      it 'shows audit lines for subjects the current user owns' do
        get '/staff/audit_logs'
        expect(response.body).to include('form.created.visible')
      end

      it 'hides audit lines for subjects the current user does not own' do
        get '/staff/audit_logs'
        expect(response.body).not_to include('form.created.hidden')
      end

      it 'shows system events (lines with no subject)' do
        get '/staff/audit_logs'
        expect(response.body).to include('system.event.visible')
      end
    end
  end
end
