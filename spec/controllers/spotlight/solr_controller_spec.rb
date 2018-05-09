describe Spotlight::SolrController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe 'when user does not have access' do
    before { sign_in FactoryBot.create(:exhibit_visitor) }

    describe 'POST update' do
      it 'does not allow update' do
        post :update, params: { exhibit_id: exhibit }
        expect(response).to redirect_to main_app.root_path
      end
    end
  end

  describe 'when user is an admin' do
    let(:admin) { FactoryBot.create(:site_admin) }
    let(:role) { admin.roles.first }
    let(:connection) { instance_double(RSolr::Client) }
    let(:repository) { instance_double(Blacklight::Solr::Repository, connection: connection) }
    before { sign_in admin }
    before do
      allow(controller).to receive(:repository).and_return(repository)
    end

    describe 'POST update' do
      it 'passes through the request data' do
        doc = {}
        expect(connection).to receive(:update) do |params|
          doc = JSON.parse(params[:data], symbolize_names: true)
        end

        post_update_with_json_body(exhibit, a: 1)

        expect(response).to be_successful
        expect(doc.first).to include a: 1
      end

      context 'when the index is not writable' do
        before do
          allow(Spotlight::Engine.config).to receive_messages(writable_index: false)
        end

        it 'raises an error' do
          post_update_with_json_body(exhibit, a: 1)

          expect(response.code).to eq '409'
        end
      end

      it 'enriches the request with exhibit solr data' do
        doc = {}
        expect(connection).to receive(:update) do |params|
          doc = JSON.parse(params[:data], symbolize_names: true)
        end

        post_update_with_json_body(exhibit, a: 1)

        expect(response).to be_successful
        expect(doc.first).to include exhibit.solr_data
      end

      it 'enriches the request with sidecar data' do
        doc = {}
        expect(connection).to receive(:update) do |params|
          doc = JSON.parse(params[:data], symbolize_names: true)
        end

        allow_any_instance_of(SolrDocument).to receive(:to_solr).and_return(b: 1)

        post_update_with_json_body(exhibit, a: 1)

        expect(response).to be_successful
        expect(doc.first).to include b: 1
      end

      context 'with a file upload' do
        let(:json) { fixture_file_upload(File.expand_path(File.join('..', 'spec', 'fixtures', 'json-upload-fixture.json'), Rails.root), 'application/json') }

        it 'parses the uploaded file' do
          doc = {}
          expect(connection).to receive(:update) do |params|
            doc = JSON.parse(params[:data], symbolize_names: true)
          end
          post :update, params: { resources_json_upload: { json: json }, exhibit_id: exhibit }

          expect(response).to redirect_to exhibit_resources_path(exhibit)
          expect(doc.first).to include a: 1
        end
      end
    end
  end

  def post_update_with_json_body(exhibit, hash)
    post :update, body: hash.to_json, params: { exhibit_id: exhibit }, as: :json
  end
end
