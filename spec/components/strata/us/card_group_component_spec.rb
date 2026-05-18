# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::US::CardGroupComponent, type: :component do
  it "renders an empty ul.usa-card-group when no cards are provided" do
    render_inline(described_class.new)

    expect(page).to have_css("ul.usa-card-group")
    expect(page).not_to have_css(".usa-card")
  end

  it "renders each card as an <li> inside the group" do
    render_inline(described_class.new) do |group|
      group.with_card do |card|
        card.with_header { "Card 1" }
        card.with_body { "Body 1" }
      end
      group.with_card do |card|
        card.with_header { "Card 2" }
        card.with_body { "Body 2" }
      end
    end

    expect(page).to have_css("ul.usa-card-group > li.usa-card", count: 2)
    expect(page).to have_css(".usa-card__heading", text: "Card 1")
    expect(page).to have_css(".usa-card__heading", text: "Card 2")
  end

  it "forwards variants and classes to the child card" do
    render_inline(described_class.new) do |group|
      group.with_card(flag: true, classes: "extra") do |card|
        card.with_body { "Body" }
      end
    end

    expect(page).to have_css("li.usa-card.usa-card--flag.extra")
  end

  it "passes html attributes to the group wrapper" do
    render_inline(described_class.new(id: "my-group", classes: "extra"))

    expect(page).to have_css("ul.usa-card-group#my-group.extra")
  end

  it "defaults each card to <li> when no tag is supplied" do
    render_inline(described_class.new) do |group|
      group.with_card do |card|
        card.with_body { "Body" }
      end
    end

    expect(page).to have_css("ul.usa-card-group > li.usa-card")
    expect(page).not_to have_css("ul.usa-card-group > div.usa-card")
  end

  it "forces each card to <li> even when a different tag is supplied" do
    render_inline(described_class.new) do |group|
      group.with_card(tag: :div) do |card|
        card.with_body { "Body" }
      end
    end

    expect(page).to have_css("ul.usa-card-group > li.usa-card")
    expect(page).not_to have_css("ul.usa-card-group > div.usa-card")
  end
end
