# frozen_string_literal: true

# Test controller for verifying layout yield :head functionality
class LayoutTestController < ApplicationController
  helper_method :header_links

  def staff_layout_without_head
    render layout: "strata/staff"
  end

  def staff_layout_with_head
    render layout: "strata/staff"
  end

  def application_layout_without_head
    render layout: "strata/application"
  end

  def application_layout_with_head
    render layout: "strata/application"
  end

  private

  def header_links
    # Provide minimal header_links for staff layout compatibility
    []
  end
end
