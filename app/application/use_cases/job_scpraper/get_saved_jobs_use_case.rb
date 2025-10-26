# アプリケーション層（ユースケース）: 保存された求人一覧を取得するユースケース
module Application
  module UseCase
    module JobScraper
      class GetSavedJobsUseCase
        def initialize(job_repository)
          @job_repository = job_repository
        end

        def execute
          jobs = @job_repository.find_all
          
          {
            success: true,
            jobs: jobs,
            total_count: jobs.count
          }
        rescue => e
          {
            success: false,
            error: e.message,
            jobs: [],
            total_count: 0
          }
        end
      end
    end
  end
end

