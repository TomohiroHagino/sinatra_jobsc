# インフラ層（モデル）: ActiveRecordを使ってsaved_jobsテーブルとマッピングする実装の詳細
module Infrastructure
  module Model
    class SavedJob < ActiveRecord::Base
      self.table_name = 'saved_jobs'

      validates :title, presence: true
      validates :company_name, presence: true
      validates :url, presence: true
      validates :source_site, presence: true

      scope :active, -> { where(is_active: true) }
      scope :by_salary_range, ->(min_salary) { where('salary_min >= ? OR salary_max >= ?', min_salary, min_salary) }
      scope :remote_work_available, -> { where(remote_work: true) }

      def to_domain_entity
        Domain::JobAggregate::Entity::SavedJobEntity.new(
          id: id,
          title: title,
          company_name: company_name,
          salary_min: salary_min,
          salary_max: salary_max,
          location: location,
          remote_work: remote_work,
          job_type: job_type,
          description: description,
          url: url,
          source_site: source_site,
          is_active: is_active,
          created_at: created_at,
          updated_at: updated_at
        )
      end
    end
  end
end

