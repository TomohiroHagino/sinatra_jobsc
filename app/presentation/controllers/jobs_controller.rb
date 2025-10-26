# プレゼンテーション層: HTTPリクエスト/レスポンスを処理し、ビューをレンダリングするコントローラー
module Presentation
  module Controller
    class JobsController < BaseApplication
      configure do
        @job_repository = Infrastructure::Repository::ActiveRecordJobRepository.new
        @scraping_service = Infrastructure::ExternalService::JobScrapingService.new
        @job_service = Application::Service::JobAggregate::JobApplicationService.new(@job_repository, @scraping_service)
      end
  
      before do
        @job_repository ||= Infrastructure::Repository::ActiveRecordJobRepository.new
        @scraping_service ||= Infrastructure::ExternalService::JobScrapingService.new
        @job_service ||= Application::Service::JobAggregate::JobApplicationService.new(@job_repository, @scraping_service)
      end
  
      get '/' do
        @saved_jobs = @job_service.get_saved_jobs
        erb :index
      end
  
      get '/scrape' do
        @scraped_jobs = @job_service.scrape_and_get_jobs
        erb :scraped_jobs
      end
  
      post '/jobs' do
        result = @job_service.save_job(params[:job])
        
        if result[:success]
          redirect '/?saved=true'
        else
          @errors = result[:errors]
          @saved_jobs = @job_service.get_saved_jobs
          erb :index
        end
      end
  
      delete '/jobs/:id' do
        result = @job_service.delete_job(params[:id])
        
        if result[:success]
          redirect '/?deleted=true'
        else
          redirect '/?error=true'
        end
      end

      get '/search' do
        criteria = {
          min_salary: params[:min_salary]&.to_i,
          remote_only: params[:remote_only] == 'true',
          company: params[:company],
          title: params[:title]
        }
        
        @jobs = @job_service.search_jobs(criteria)
        erb :search_results
      end
    end
  end
end
