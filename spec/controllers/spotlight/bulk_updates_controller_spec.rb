# frozen_string_literal: true

RSpec.describe Spotlight::BulkUpdatesController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe 'when the user is not authorized' do
    before do
      sign_in FactoryBot.create(:exhibit_visitor)
    end

    describe 'GET edit' do
      it 'denies access' do
        get :edit, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end

    describe 'POST download_template' do
      it 'denies access' do
        post :download_template, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'when the user is a curator' do
    before do
      sign_in FactoryBot.create(:exhibit_curator, exhibit:)
    end

    describe 'GET edit' do
      it 'is allowed' do
        get :edit, params: { exhibit_id: exhibit }
        expect(response).to be_successful
      end
    end

    describe 'POST download_template' do
      it 'downloads a CSV template' do
        post :download_template, params: {
          exhibit_id: exhibit,
          reference_fields: { item_id: 1, item_title: 1 },
          updatable_fields: { tags: 0, visibility: 1 }
        }

        body_content = response.body.is_a?(Enumerator) ? response.body.to_a.join : response.body
        content = CSV.parse(body_content)
        expect(content.length).to eq(56)
        expect(content[0]).to eq ['Item ID', 'Item Title', 'Visibility']
      end
    end

    describe 'PATCH download_template' do
      it 'uploads the given CSV template and passes it to a job' do
        expect do
          patch :update, params: {
            exhibit_id: exhibit,
            file: fixture_file_upload('spec/fixtures/bulk-update-template.csv', 'text/csv')
          }
        end.to(have_enqueued_job(Spotlight::ProcessBulkUpdatesCsvJob).with do |job_exhibit, uploader|
          expect(job_exhibit).to eq exhibit
          expect(uploader).to be_a Spotlight::BulkUpdate
          expect(uploader.file_identifier).to eq 'bulk-update-template.csv'
        end)

        expect(flash[:notice]).to eq 'The CSV file was uploaded successfully.'
        expect(response).to redirect_to(spotlight.edit_exhibit_bulk_updates_path(exhibit))
      end
    end
  end
end
