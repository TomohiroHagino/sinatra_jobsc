# 依存性注入の設定
job_repository = Infrastructure::Repository::ActiveRecordJobRepository.new
scraping_service = Infrastructure::ExternalService::JobScrapingService.new
job_service = Application::Service::JobScraper::JobApplicationService.new(job_repository, scraping_service)

# コントローラーにアプリケーションサービスを注入
Presentation::Controller::JobsController.job_service = job_service

# ルーティング設定
class App < BaseApplication
  use Presentation::Controller::JobsController
end
