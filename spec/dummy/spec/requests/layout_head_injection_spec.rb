# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Layout head injection", type: :request do
  describe "strata/staff layout" do
    context "when view does not provide content_for :head" do
      it "renders successfully without errors" do
        get "/layout_test/staff_layout_without_head"
        expect(response).to have_http_status(:ok)
      end

      it "does not include custom head content" do
        get "/layout_test/staff_layout_without_head"
        expect(response.body).not_to include('test-injected')
        expect(response.body).not_to include('Custom staff head content')
      end

      it "includes standard head elements" do
        get "/layout_test/staff_layout_without_head"

        # Should have standard meta tags
        expect(response.body).to include('<meta name="viewport"')

        # Should have standard scripts (with asset pipeline digest)
        expect(response.body).to match(/uswds-init\.min.*\.js/)
      end
    end

    context "when view provides content_for :head" do
      it "renders successfully" do
        get "/layout_test/staff_layout_with_head"
        expect(response).to have_http_status(:ok)
      end

      it "includes the custom head content" do
        get "/layout_test/staff_layout_with_head"

        # Should include custom meta tag
        expect(response.body).to include('<meta name="test-injected" content="staff-custom-head">')

        # Should include custom script
        expect(response.body).to include("console.log('Custom staff head content');")
      end

      it "injects content inside <head> tags" do
        get "/layout_test/staff_layout_with_head"

        # Extract just the head section
        head_section = response.body.match(/<head>(.*?)<\/head>/m)[1]

        # Custom content should be in the head
        expect(head_section).to include('test-injected')
        expect(head_section).to include('Custom staff head content')
      end

      it "includes both standard and custom head elements" do
        get "/layout_test/staff_layout_with_head"

        # Should have standard elements (with asset pipeline digest)
        expect(response.body).to match(/uswds-init\.min.*\.js/)

        # Should have custom elements
        expect(response.body).to include('test-injected')
      end
    end
  end

  describe "strata/application layout" do
    context "when view does not provide content_for :head" do
      it "renders successfully without errors" do
        get "/layout_test/application_layout_without_head"
        expect(response).to have_http_status(:ok)
      end

      it "does not include custom head content" do
        get "/layout_test/application_layout_without_head"
        expect(response.body).not_to include('test-injected')
        expect(response.body).not_to include('Custom application head content')
      end

      it "includes standard head elements" do
        get "/layout_test/application_layout_without_head"

        # Should have standard elements
        expect(response.body).to include('<title>Strata</title>')
        expect(response.body).to include('<head>')
      end
    end

    context "when view provides content_for :head" do
      it "renders successfully" do
        get "/layout_test/application_layout_with_head"
        expect(response).to have_http_status(:ok)
      end

      it "includes the custom head content" do
        get "/layout_test/application_layout_with_head"

        # Should include custom meta tag
        expect(response.body).to include('<meta name="test-injected" content="application-custom-head">')

        # Should include custom script
        expect(response.body).to include("console.log('Custom application head content');")
      end

      it "injects content inside <head> tags" do
        get "/layout_test/application_layout_with_head"

        # Extract just the head section
        head_section = response.body.match(/<head>(.*?)<\/head>/m)[1]

        # Custom content should be in the head
        expect(head_section).to include('test-injected')
        expect(head_section).to include('Custom application head content')
      end

      it "includes both standard and custom head elements" do
        get "/layout_test/application_layout_with_head"

        # Should have standard elements
        expect(response.body).to include('<title>Strata</title>')

        # Should have custom elements
        expect(response.body).to include('test-injected')
      end
    end
  end

  describe "real-world use case: importmap injection" do
    it "can inject javascript_importmap_tags into staff layout" do
      # This simulates what OSCER needs to do
      get "/layout_test/staff_layout_with_head"

      # The test view includes a script tag - verify it renders in head
      head_section = response.body.match(/<head>(.*?)<\/head>/m)[1]
      expect(head_section).to include('<script>')
    end

    it "can inject javascript_importmap_tags into application layout" do
      # This simulates what any host app might need
      get "/layout_test/application_layout_with_head"

      # The test view includes a script tag - verify it renders in head
      head_section = response.body.match(/<head>(.*?)<\/head>/m)[1]
      expect(head_section).to include('<script>')
    end
  end
end
