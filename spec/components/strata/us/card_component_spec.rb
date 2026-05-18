# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::US::CardComponent, type: :component do
  it "renders a basic card with default classes" do
    render_inline(described_class.new) do |card|
      card.with_body { "Body content" }
    end

    expect(page).to have_css("div.usa-card > .usa-card__container")
    expect(page).not_to have_css(".usa-card--flag")
    expect(page).not_to have_css(".usa-card--media-right")
    expect(page).not_to have_css(".usa-card--header-first")
  end

  it "renders header, media, body, and footer when all slots are provided" do
    render_inline(described_class.new) do |card|
      card.with_header { "My Card" }
      card.with_media { "<img src='img.png' alt='alt' />".html_safe }
      card.with_body { "<p>Body</p>".html_safe }
      card.with_footer { "<button>Action</button>".html_safe }
    end

    expect(page).to have_css(".usa-card__header .usa-card__heading", text: "My Card")
    expect(page).to have_css(".usa-card__media .usa-card__img img[src='img.png']")
    expect(page).to have_css(".usa-card__body p", text: "Body")
    expect(page).to have_css(".usa-card__footer button", text: "Action")
  end

  it "uses h4 as the default heading tag" do
    render_inline(described_class.new) do |card|
      card.with_header { "Title" }
    end

    expect(page).to have_css("h4.usa-card__heading", text: "Title")
  end

  it "applies a custom heading tag" do
    render_inline(described_class.new(heading_tag: :h2)) do |card|
      card.with_header { "Title" }
    end

    expect(page).to have_css("h2.usa-card__heading", text: "Title")
  end

  context "when a slot is omitted" do
    it "does not render the header element when header is omitted" do
      render_inline(described_class.new) do |card|
        card.with_body { "Body" }
      end

      expect(page).not_to have_css(".usa-card__header")
    end

    it "does not render the media element when media is omitted" do
      render_inline(described_class.new) do |card|
        card.with_body { "Body" }
      end

      expect(page).not_to have_css(".usa-card__media")
    end

    it "does not render the body element when body is omitted" do
      render_inline(described_class.new) do |card|
        card.with_header { "Title" }
      end

      expect(page).not_to have_css(".usa-card__body")
    end

    it "does not render the footer element when footer is omitted" do
      render_inline(described_class.new) do |card|
        card.with_header { "Title" }
      end

      expect(page).not_to have_css(".usa-card__footer")
    end
  end

  context "variant classes" do
    it "applies the flag variant" do
      render_inline(described_class.new(flag: true)) do |card|
        card.with_body { "Body" }
      end

      expect(page).to have_css(".usa-card.usa-card--flag")
    end

    it "applies the flag-media-right variant and implies flag" do
      render_inline(described_class.new(flag_media_right: true)) do |card|
        card.with_body { "Body" }
      end

      expect(page).to have_css(".usa-card.usa-card--flag.usa-card--media-right")
    end

    it "applies the header-first variant" do
      render_inline(described_class.new(header_first: true)) do |card|
        card.with_body { "Body" }
      end

      expect(page).to have_css(".usa-card.usa-card--header-first")
    end

    it "applies media-inset on the media element when media_inset is true" do
      render_inline(described_class.new(media_inset: true)) do |card|
        card.with_media { "<img src='img.png' alt='alt' />".html_safe }
      end

      expect(page).to have_css(".usa-card__media.usa-card__media--inset")
    end

    it "applies media-exdent on the media element when media_exdent is true" do
      render_inline(described_class.new(media_exdent: true)) do |card|
        card.with_media { "<img src='img.png' alt='alt' />".html_safe }
      end

      expect(page).to have_css(".usa-card__media.usa-card__media--exdent")
    end

    it "does not render media variants when media slot is empty" do
      render_inline(described_class.new(media_inset: true, media_exdent: true)) do |card|
        card.with_body { "Body" }
      end

      expect(page).not_to have_css(".usa-card__media")
      expect(page).not_to have_css(".usa-card__media--inset")
      expect(page).not_to have_css(".usa-card__media--exdent")
    end
  end

  context "custom classes and html attributes" do
    it "appends custom classes to the wrapper" do
      render_inline(described_class.new(classes: "extra-class another-class")) do |card|
        card.with_body { "Body" }
      end

      expect(page).to have_css(".usa-card.extra-class.another-class")
    end

    it "passes html attributes through to the wrapper" do
      render_inline(described_class.new(id: "my-card", data: { test: "value" })) do |card|
        card.with_body { "Body" }
      end

      expect(page).to have_css("div.usa-card#my-card[data-test='value']")
    end
  end

  context "when rendered as a list item" do
    it "uses li as the wrapper tag when tag: :li is passed" do
      render_inline(described_class.new(tag: :li)) do |card|
        card.with_body { "Body" }
      end

      expect(page).to have_css("li.usa-card > .usa-card__container")
      expect(page).not_to have_css("div.usa-card")
    end
  end
end
