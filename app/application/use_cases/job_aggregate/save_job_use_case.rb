# アプリケーション層（ユースケース）: 求人情報をデータベースに保存するユースケース
module Application
  module UseCase
    module JobAggregate
      class SaveJobUseCase
        def initialize(job_repository)
          @job_repository = job_repository
        end

        def execute(job_data)
          job = Domain::JobAggregate::Entity::JobEntity.new(job_data)
          
          return { success: false, errors: job.errors.full_messages } unless job.valid?

          saved_job = @job_repository.save(job)
          { success: true, job: saved_job }
        rescue => e
          { success: false, error: e.message }
        end
      end
    end
  end
end

