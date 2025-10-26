# 依存性注入の設定
job_repository = Infrastructure::Repository::ActiveRecordJobRepository.new
scraping_service = Infrastructure::ExternalService::JobScrapingService.new
job_service = Application::Service::JobAggregate::JobApplicationService.new(job_repository, scraping_service)

# ルーティング設定
class App < BaseApplication
  use Presentation::Controller::JobsController
end
