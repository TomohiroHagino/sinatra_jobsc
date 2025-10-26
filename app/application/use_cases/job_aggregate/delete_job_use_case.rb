# アプリケーション層（ユースケース）: 求人情報をデータベースから削除するユースケース
module Application
  module UseCase
    module JobAggregate
      class DeleteJobUseCase
        def initialize(job_repository)
          @job_repository = job_repository
        end

        def execute(job_id)
          @job_repository.delete(job_id)
          { success: true }
        rescue ActiveRecord::RecordNotFound
          { success: false, error: 'Job not found' }
        rescue => e
          { success: false, error: e.message }
        end
      end
    end
  end
end

