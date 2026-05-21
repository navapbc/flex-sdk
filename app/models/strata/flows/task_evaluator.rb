# frozen_string_literal: true

module Strata::Flows
  # Evaluates a task within the context of a given record and the current page.
  # When the current position is inside a Loop, the evaluator also carries the
  # active child record and the index within the loop's pages so traversal
  # methods can move both within the loop and out of it.
  class TaskEvaluator
    attr_accessor :task, :record, :current_page_idx, :loop_record, :loop_page_idx

    def initialize(task, record, current_page_idx, loop_record: nil, loop_page_idx: nil)
      @task = task
      @record = record
      @current_page_idx = current_page_idx
      @loop_record = loop_record
      @loop_page_idx = loop_page_idx
    end

    def started?
      @task.started?(record)
    end

    def completed?
      @task.completed?(record)
    end

    def pages
      @task.pages
    end

    def path
      @task.path
    end

    def current_loop
      item = @task.pages[@current_page_idx]
      item.is_a?(Loop) ? item : nil
    end

    def in_loop?
      current_loop.present?
    end

    def current_page
      in_loop? ? current_loop.pages[@loop_page_idx] : @task.pages[@current_page_idx]
    end

    def update_path
      in_loop? ? current_page.update_path(@record, @loop_record) : current_page.update_path(@record)
    end

    def prev_path
      if in_loop?
        within = step_within_loop_backward
        return within if within
      end

      walk_outer_backward(@current_page_idx)
    end

    def next_path
      if in_loop?
        within = step_within_loop_forward
        return within if within
      end

      walk_outer_forward(@current_page_idx)
    end

    private

    def step_within_loop_forward
      loop_node = current_loop

      idx = @loop_page_idx + 1
      while idx < loop_node.pages.length
        page = loop_node.pages[idx]
        return page.edit_path(@record, @loop_record) if page.needed?(@loop_record)
        idx += 1
      end

      advance_to_next_loop_record(loop_node)
    end

    def step_within_loop_backward
      loop_node = current_loop

      idx = @loop_page_idx - 1
      while idx >= 0
        page = loop_node.pages[idx]
        return page.edit_path(@record, @loop_record) if page.needed?(@loop_record)
        idx -= 1
      end

      retreat_to_previous_loop_record(loop_node)
    end

    def advance_to_next_loop_record(loop_node)
      records = loop_node.records_for(@record)
      current_idx = records.find_index(@loop_record)
      return nil unless current_idx

      next_idx = current_idx + 1
      while next_idx < records.length
        child = records[next_idx]
        page = first_needed_page(loop_node.pages, child)
        return page.edit_path(@record, child) if page
        next_idx += 1
      end

      nil
    end

    def retreat_to_previous_loop_record(loop_node)
      records = loop_node.records_for(@record)
      current_idx = records.find_index(@loop_record)
      return nil unless current_idx

      prev_idx = current_idx - 1
      while prev_idx >= 0
        child = records[prev_idx]
        page = last_needed_page(loop_node.pages, child)
        return page.edit_path(@record, child) if page
        prev_idx -= 1
      end

      nil
    end

    def walk_outer_forward(starting_idx)
      idx = starting_idx + 1
      while idx < @task.pages.length
        path = enter_forward(@task.pages[idx])
        return path if path
        idx += 1
      end
      nil
    end

    def walk_outer_backward(starting_idx)
      idx = starting_idx - 1
      while idx >= 0
        path = enter_backward(@task.pages[idx])
        return path if path
        idx -= 1
      end
      nil
    end

    def enter_forward(item)
      if item.is_a?(Loop)
        item.records_for(@record).each do |child|
          page = first_needed_page(item.pages, child)
          return page.edit_path(@record, child) if page
        end
        nil
      else
        item.needed?(@record) ? item.edit_path(@record) : nil
      end
    end

    def enter_backward(item)
      if item.is_a?(Loop)
        item.records_for(@record).reverse_each do |child|
          page = last_needed_page(item.pages, child)
          return page.edit_path(@record, child) if page
        end
        nil
      else
        item.needed?(@record) ? item.edit_path(@record) : nil
      end
    end

    def first_needed_page(pages, child_record)
      pages.find { |p| p.needed?(child_record) }
    end

    def last_needed_page(pages, child_record)
      pages.reverse.find { |p| p.needed?(child_record) }
    end
  end
end
