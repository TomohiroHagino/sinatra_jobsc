# インフラ層（リポジトリ）: ActiveRecordを使用してデータベースから求人データを取得・保存するリポジトリ実装
module Infrastructure
  module Repository
    class ActiveRecordJobRepository < Domain::Repository::JobScraper::JobRepository
        def find_all
        Infrastructure::Model::SavedJob.active.order(created_at: :desc).map(&:to_domain_entity)
      end

        def find_by_id(id)
        saved_job = Infrastructure::Model::SavedJob.find_by(id: id)
        saved_job&.to_domain_entity
      end

        def save(job)
        if job.id
          update_existing_job(job)
        else
          create_new_job(job)
        end
      end

        def delete(id)
        Infrastructure::Model::SavedJob.find(id).destroy
      end

        def find_by_criteria(criteria)
        query = Infrastructure::Model::SavedJob.active

        query = query.where('salary_min >= ? OR salary_max >= ?', criteria[:min_salary], criteria[:min_salary]) if criteria[:min_salary]
        query = query.where(remote_work: true) if criteria[:remote_only]
        query = query.where('company_name LIKE ?', "%#{criteria[:company]}%") if criteria[:company]
        query = query.where('title LIKE ?', "%#{criteria[:title]}%") if criteria[:title]

        query.order(created_at: :desc).map(&:to_domain_entity)
      end

      private

        def update_existing_job(job)
        saved_job = Infrastructure::Model::SavedJob.find(job.id)
        saved_job.update!(
          title: job.title,
          company_name: job.company_name,
          salary_min: job.salary_min,
          salary_max: job.salary_max,
          location: job.location,
          remote_work: job.remote_work,
          job_type: job.job_type,
          description: job.description,
          url: job.url,
          source_site: job.source_site,
          is_active: job.is_active
        )
        saved_job.to_domain_entity
      end

        def create_new_job(job)
        saved_job = Infrastructure::Model::SavedJob.create!(
          title: job.title,
          company_name: job.company_name,
          salary_min: job.salary_min,
          salary_max: job.salary_max,
          location: job.location,
          remote_work: job.remote_work,
          job_type: job.job_type,
          description: job.description,
          url: job.url,
          source_site: job.source_site,
          is_active: job.is_active
        )
        saved_job.to_domain_entity
      end
    end
  end
end

