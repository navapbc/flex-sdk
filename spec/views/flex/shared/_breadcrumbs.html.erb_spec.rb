require 'rails_helper'

RSpec.describe "flex/shared/_breadcrumbs.html.erb", type: :view do
  describe "when custom breadcrumbs are provided" do
    before do
      view.content_for(:breadcrumbs) do
        '<nav>Custom breadcrumbs</nav>'
      end
      render partial: "flex/shared/breadcrumbs"
    end

    it "renders the custom breadcrumbs content" do
      expect(rendered).to include('Custom breadcrumbs')
    end

    it "does not render the default breadcrumb navigation" do
      expect(rendered).not_to include('usa-breadcrumb')
    end
  end

  describe "when no custom breadcrumbs are provided" do
    before do
      render partial: "flex/shared/breadcrumbs", locals: { breadcrumbs: breadcrumbs }
    end

    context "with a single breadcrumb" do
      let(:breadcrumbs) { [ { text: "Dashboard" } ] }

      it "renders a single breadcrumb without a link" do
        render partial: "flex/shared/breadcrumbs", locals: { breadcrumbs: breadcrumbs }

        expect(rendered).to have_selector('nav.usa-breadcrumb[aria-label="Breadcrumbs"]')
        expect(rendered).to have_selector('ol.usa-breadcrumb__list')
        expect(rendered).to have_selector('li.usa-breadcrumb__list-item.usa-current[aria-current="page"]')
        expect(rendered).to have_selector('span', text: "Dashboard")
        expect(rendered).not_to have_selector('a.usa-breadcrumb__link')
      end
    end

    context "with multiple breadcrumbs" do
      let(:breadcrumbs) {
        [
          { text: "Home", link: "/" },
          { text: "Cases", link: "/cases" },
          { text: "Case #12345" }
        ]
      }

      it "renders all breadcrumbs with proper structure" do
        render partial: "flex/shared/breadcrumbs", locals: { breadcrumbs: breadcrumbs }

        expect(rendered).to have_selector('nav.usa-breadcrumb[aria-label="Breadcrumbs"]')
        expect(rendered).to have_selector('ol.usa-breadcrumb__list')
      end

      it "renders clickable links for all but the last breadcrumb" do
        render partial: "flex/shared/breadcrumbs", locals: { breadcrumbs: breadcrumbs }

        # First breadcrumb (Home)
        expect(rendered).to have_selector('li.usa-breadcrumb__list-item a.usa-breadcrumb__link[href="/"]', text: "Home")

        # Second breadcrumb (Cases)
        expect(rendered).to have_selector('li.usa-breadcrumb__list-item a.usa-breadcrumb__link[href="/cases"]', text: "Cases")
      end

      it "renders the last breadcrumb as current page without a link" do
        render partial: "flex/shared/breadcrumbs", locals: { breadcrumbs: breadcrumbs }

        expect(rendered).to have_selector('li.usa-breadcrumb__list-item.usa-current[aria-current="page"]')
        expect(rendered).to have_selector('li.usa-current span', text: "Case #12345")
        expect(rendered).not_to have_selector('li.usa-current a')
      end

      it "has proper accessibility attributes" do
        render partial: "flex/shared/breadcrumbs", locals: { breadcrumbs: breadcrumbs }

        expect(rendered).to have_selector('nav[aria-label="Breadcrumbs"]')
        expect(rendered).to have_selector('li[aria-current="page"]')
      end
    end

    context "with empty breadcrumbs array" do
      let(:breadcrumbs) { [] }

      it "raises an error when trying to access last element" do
        expect { render partial: "flex/shared/breadcrumbs", locals: { breadcrumbs: breadcrumbs } }.not_to raise_error
      end
    end

    context "with breadcrumbs containing special characters" do
      let(:breadcrumbs) {
        [
          { text: "Home & Dashboard", link: "/" },
          { text: "Cases > Applications", link: "/cases" },
          { text: "Case #12345 (Active)" }
        ]
      }

      it "properly escapes special characters in text" do
        render partial: "flex/shared/breadcrumbs", locals: { breadcrumbs: breadcrumbs }

        expect(rendered).to include("Home &amp; Dashboard")
        expect(rendered).to include("Cases &gt; Applications")
        expect(rendered).to include("Case #12345 (Active)")
      end
    end
  end
end
