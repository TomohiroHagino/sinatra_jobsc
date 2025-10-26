# ドメイン層（ファクトリ）: エンティティの作成を隠蔽し、複雑な生成ロジックをカプセル化するファクトリ
module Domain
  module JobScraper
    module Factory
      class JobFactory
        def self.create_from_scraped_data(data)
          Job.new(
            title: data[:title],
            company_name: data[:company_name],
            salary_min: data[:salary_min],
            salary_max: data[:salary_max],
            location: data[:location],
            remote_work: data[:remote_work] || false,
            job_type: data[:job_type] || '正社員',
            description: data[:description],
            url: data[:url],
            source_site: data[:source_site],
            is_active: true
          )
        end
      
        def self.create_from_params(params)
          Job.new(
            title: params[:title],
            company_name: params[:company_name],
            salary_min: params[:salary_min],
            salary_max: params[:salary_max],
            location: params[:location],
            remote_work: params[:remote_work] || false,
            job_type: params[:job_type] || '正社員',
            description: params[:description],
            url: params[:url],
            source_site: params[:source_site],
            is_active: params[:is_active] != false
          )
        end
      
        def self.create_sample_job
          Job.new(
            title: "Rails エンジニア募集",
            company_name: "サンプル株式会社",
            salary_min: 80,
            salary_max: 120,
            location: "東京都",
            remote_work: true,
            job_type: "正社員",
            description: "Rails を使ったWebアプリケーション開発を行います。",
            url: "https://example.com/job/sample",
            source_site: "サンプルサイト",
            is_active: true
          )
        end
      end
    end
  end
end
