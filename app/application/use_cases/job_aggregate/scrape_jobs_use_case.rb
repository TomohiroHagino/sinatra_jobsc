# アプリケーション層（ユースケース）: 外部サイトから求人をスクレイピングするユースケース
module Application
  module UseCase
    module JobAggregate
      class ScrapeJobsUseCase
        def initialize(scraping_service)
          @scraping_service = scraping_service
        end

        def execute
          jobs = @scraping_service.scrape_all_sites
          
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

