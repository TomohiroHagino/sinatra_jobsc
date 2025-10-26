class CreateSavedJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :saved_jobs do |t|
      t.string :title, null: false
      t.string :company_name, null: false
      t.integer :salary_min
      t.integer :salary_max
      t.string :location
      t.boolean :remote_work, default: false
      t.string :job_type
      t.text :description
      t.string :url, null: false
      t.string :source_site, null: false
      t.boolean :is_active, default: true

      t.timestamps
    end

    add_index :saved_jobs, :source_site
    add_index :saved_jobs, :is_active
    add_index :saved_jobs, :remote_work
    add_index :saved_jobs, [:salary_min, :salary_max]
  end
end
