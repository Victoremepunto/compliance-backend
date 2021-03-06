# frozen_string_literal: true

require 'swagger_helper'

describe 'Systems API' do
  before do
    @account = FactoryBot.create(:account)
    @host = FactoryBot.create(:host, account: @account.account_number)
  end

  path "#{Settings.path_prefix}/#{Settings.app_name}/systems" do
    get 'List all hosts' do
      tags 'host'
      description 'Lists all hosts requested'
      operationId 'ListHosts'

      content_types
      auth_header
      pagination_params
      search_params
      sort_params

      include_param

      response '200', 'lists all hosts requested' do
        let(:'X-RH-IDENTITY') { encoded_header(@account) }
        let(:include) { '' } # work around buggy rswag
        schema type: :object,
               properties: {
                 meta: ref_schema('metadata'),
                 links: ref_schema('links'),
                 data: {
                   type: :array,
                   items: {
                     properties: {
                       type: { type: :string },
                       id: ref_schema('uuid'),
                       attributes: ref_schema('host'),
                       relationships: ref_schema('host_relationships')
                     }
                   }
                 }
               }

        after { |e| autogenerate_examples(e) }

        run_test!
      end
    end
  end

  path "#{Settings.path_prefix}/#{Settings.app_name}/systems/{id}" do
    get 'Retrieve a system' do
      tags 'host'
      description 'Lists all hosts requested'
      operationId 'ListHosts'

      content_types
      auth_header

      parameter name: :id, in: :path, type: :string
      include_param

      response '404', 'system not found' do
        let(:id) { 'invalid' }
        let(:'X-RH-IDENTITY') { encoded_header }
        let(:include) { '' } # work around buggy rswag
        after { |e| autogenerate_examples(e) }
        run_test!
      end

      response '200', 'retrieves a system' do
        let(:'X-RH-IDENTITY') { encoded_header(@account) }
        let(:id) { @host.id }
        let(:include) { '' } # work around buggy rswag
        schema type: :object,
               properties: {
                 meta: ref_schema('metadata'),
                 links: ref_schema('links'),
                 data: {
                   type: :object,
                   properties: {
                     type: { type: :string },
                     id: ref_schema('uuid'),
                     attributes: ref_schema('host'),
                     relationships: ref_schema('host_relationships')
                   }
                 }
               }
        after { |e| autogenerate_examples(e) }

        run_test!
      end
    end
  end
end
