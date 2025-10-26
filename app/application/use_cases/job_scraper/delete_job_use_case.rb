# アプリケーション層（ユースケース）: 求人情報をデータベースから削除するユースケース
module Application
  module UseCase
    module JobScraper
      class DeleteJobUseCase
        def initialize(job_repository)
          @job_repository = job_repository
        end

        def execute(job_id)
          job = @job_repository.find_by_id(job_id)
          return { success: false, errors: ['求人情報が見つかりません'] } unless job
          
          @job_repository.delete(job_id)
          { success: true }
        rescue => e
          { success: false, errors: [e.message] }
        end
      end
    end
  end
end

