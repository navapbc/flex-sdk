require 'rails_helper'

RSpec.describe "flex/cases/_sidenav.html.erb", type: :view do
  context "when content_for(:sidenav) is provided" do
    before do
      view.content_for(:sidenav) do
        '<div>Custom sidenav</div>'
      end
      render partial: "flex/cases/sidenav", locals: { sidenav: [] }
    end

    it "renders the custom sidenav" do
      render partial: "flex/cases/sidenav"
      expect(rendered).to include("Custom sidenav")
    end
  end

  context "when sidenav items are provided" do
    let(:sidenav) do
      [
        { text: "Overview", link: "/cases/123" },
        { text: "Documents", link: "/cases/123/documents" },
        { text: "Tasks", link: "/cases/123/tasks" }
      ]
    end

    before do
      render partial: "flex/cases/sidenav", locals: { sidenav: sidenav }
    end

    it "renders the custom sidenav with the correct links" do
      expect(rendered).to have_css('li.usa-sidenav__item a[href="/cases/123"]', text: "Overview")
      expect(rendered).to have_css('li.usa-sidenav__item a[href="/cases/123/documents"]', text: "Documents")
      expect(rendered).to have_css('li.usa-sidenav__item a[href="/cases/123/tasks"]', text: "Tasks")
    end

    context "when current path matches a navigation item" do
      let(:request_path) { "/cases/123/documents" }

      before do
        allow(view).to receive(:request).and_return(double(path: request_path))
        render partial: "flex/cases/sidenav", locals: { sidenav: sidenav }
      end

      it "adds usa-current class to the matching link" do
        expect(rendered).to have_css('li.usa-sidenav__item a.usa-current', text: "Documents")
        expect(rendered).to have_css('li.usa-sidenav__item a.usa-current[href="/cases/123/documents"]')
      end

      it "does not add usa-current class to non-matching links" do
        expect(rendered).not_to have_css('li.usa-sidenav__item a.usa-current', text: "Overview")
        expect(rendered).not_to have_css('li.usa-sidenav__item a.usa-current', text: "Tasks")
        expect(rendered).not_to have_css('li.usa-sidenav__item a.usa-current', text: "History")
      end
    end

    context "when current path does not match any navigation item" do
      let(:request_path) { "/cases/123/settings" }

      before do
        allow(view).to receive(:request).and_return(double(path: request_path))
        render partial: "flex/cases/sidenav", locals: { sidenav: sidenav }
      end

      it "does not add usa-current class to any links" do
        expect(rendered).not_to have_css('li.usa-sidenav__item a.usa-current')
      end
    end
  end

  context "when sidenav is an empty array" do
    before do
      render partial: "flex/cases/sidenav", locals: { sidenav: [] }
    end

    it "renders the sidenav navigation with no items" do
      expect(rendered).to have_css('nav')
      expect(rendered).not_to have_css('li.usa-sidenav__item')
    end
  end
end
