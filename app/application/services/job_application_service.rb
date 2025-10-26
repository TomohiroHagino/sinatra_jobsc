# アプリケーション層: ユースケースを呼び出すアプリケーションサービス（オーケストレーター）
module Application
  module Service
    module JobAggregate
      class JobApplicationService
        def initialize(job_repository, scraping_service)
          @job_repository = job_repository
          @scraping_service = scraping_service

          # ユースケースの初期化
          @get_saved_jobs_use_case = Application::UseCase::JobAggregate::GetSavedJobsUseCase.new(job_repository)
          @scrape_jobs_use_case = Application::UseCase::JobAggregate::ScrapeJobsUseCase.new(scraping_service)
          @save_job_use_case = Application::UseCase::JobAggregate::SaveJobUseCase.new(job_repository)
          @delete_job_use_case = Application::UseCase::JobAggregate::DeleteJobUseCase.new(job_repository)
          @search_jobs_use_case = Application::UseCase::JobAggregate::SearchJobsUseCase.new(job_repository)
        end

        def scrape_and_get_jobs
          result = @scrape_jobs_use_case.execute
          result[:jobs] || []
        end

        def get_saved_jobs
          result = @get_saved_jobs_use_case.execute
          result[:jobs] || []
        end

        def save_job(job_data)
          @save_job_use_case.execute(job_data)
        end

        def delete_job(id)
          @delete_job_use_case.execute(id)
        end
  
        def search_jobs(criteria)
          result = @search_jobs_use_case.execute(criteria)
          result[:jobs] || []
        end
      end
    end
  end
end


