# This migration comes from flex (originally 20250624223240)
class CreateFlexBusinessProcesses < ActiveRecord::Migration[8.0]
  def change
    create_table :flex_business_processes do |t|
      t.string :type, index: true
      t.uuid :case_id, index: true
      t.string :case_type
      t.string :current_step

      t.timestamps
    end

    # Uncomment the following lines to bulk migrate existing cases to
    # flex_business_processes.
    # You'll want to do this for each case type you have in your application.
    # Replace "MyBusinessProcess" and "MyCase" with your actual business process
    # and case model names.
    # 
    # values = MyCase.open.map do |kase|
    #   "('MyBusinessProcess', '#{kase.id}', 'MyCase', '#{kase.business_process_current_step}', NOW(), NOW())"
    # end
    #
    # if values.any?
    #   execute <<-SQL
    #     INSERT INTO flex_business_processes (type, case_id, case_type, current_step, created_at, updated_at)
    #     VALUES #{values.join(",")}
    #   SQL
    # end
  end
end
