require 'rails_helper'

RSpec.describe Strata::ApplicationHelper, type: :helper do
  describe '#strata_form_with' do
    it 'sets builder, forwards options, includes :model when provided, and returns form_with result' do
      dummy_model = instance_double(Object)

      allow(helper).to receive(:form_with).and_return(:result)

      result = helper.strata_form_with(
        model: dummy_model,
        scope: :user,
        url: '/submit',
        format: :json,
        local: true,
        method: :patch,
        data: { foo: 'bar' }
      ) { :yielded }

      expect(helper).to have_received(:form_with).with(
        hash_including(
          builder: Strata::FormBuilder,
          scope: :user,
          url: '/submit',
          format: :json,
          local: true,
          method: :patch,
          data: { foo: 'bar' },
          model: dummy_model
        )
      )
      expect(result).to eq(:result)
    end

    it 'omits :model when model is falsey' do
      allow(helper).to receive(:form_with) do |**args, &blk|
        expect(args).not_to have_key(:model)
        :no_model
      end

      result = helper.strata_form_with(scope: :user) { :yielded }
      expect(result).to eq(:no_model)
    end
  end
end
