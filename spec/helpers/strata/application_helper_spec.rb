require 'rails_helper'

RSpec.describe Strata::ApplicationHelper, type: :helper do
  describe '#strata_form_with' do
    it 'sets the builder, forwards options, includes :model when provided, and yields the block' do
      dummy_model = double('Model')

      expect(helper).to receive(:form_with) do |**args, &blk|
        expect(args[:builder]).to eq(Strata::FormBuilder)
        expect(args[:scope]).to eq(:user)
        expect(args[:url]).to eq('/submit')
        expect(args[:format]).to eq(:json)

        # forwards arbitrary options
        expect(args[:local]).to eq(true)
        expect(args[:method]).to eq(:patch)
        expect(args[:data]).to eq({ foo: 'bar' })

        # includes model when provided
        expect(args[:model]).to eq(dummy_model)

        expect(blk).to be_a(Proc)
        :result
      end

      result = helper.strata_form_with(
        model: dummy_model,
        scope: :user,
        url: '/submit',
        format: :json,
        local: true,
        method: :patch,
        data: { foo: 'bar' }
      ) { :yielded }

      expect(result).to eq(:result)
    end

    it 'omits :model when model is falsey' do
      expect(helper).to receive(:form_with) do |**args, &blk|
        expect(args).not_to have_key(:model)
        :no_model
      end

      result = helper.strata_form_with(scope: :user) { :yielded }
      expect(result).to eq(:no_model)
    end
  end
end


