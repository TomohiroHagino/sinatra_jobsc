# アプリケーション層（ユースケース）: 条件に基づいて求人を検索するユースケース
module Application
  module UseCase
    module JobAggregate
      class SearchJobsUseCase
        def initialize(job_repository)
          @job_repository = job_repository
        end

        def execute(criteria)
          jobs = @job_repository.find_by_criteria(criteria)
          
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

