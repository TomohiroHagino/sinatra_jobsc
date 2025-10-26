# インフラ層（外部サービス）: 外部サイトから求人情報をスクレイピングするサービス
require 'nokogiri'
require 'httparty'
require 'selenium-webdriver'

module Infrastructure
  module ExternalService
    class JobScrapingService
        include HTTParty

        BASE_URLS = {
        'findy' => 'https://findy.jp',
        'chokufuri' => 'https://chokufuri.jp',
        'offers' => 'https://offers.jp',
        'wantedly' => 'https://www.wantedly.com',
        'indeed' => 'https://jp.indeed.com',
      }.freeze

      def initialize
        @headers = {
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
        @use_selenium = ENV['USE_SELENIUM'] == 'true'
      end

      def scrape_with_selenium(url, wait_time: 3)
        begin
          options = Selenium::WebDriver::Chrome::Options.new
          options.add_argument('--headless=new')
          options.add_argument('--disable-gpu')
          options.add_argument('--no-sandbox')
          options.add_argument('--disable-dev-shm-usage')
          options.add_argument('--disable-blink-features=AutomationControlled')
          options.add_argument('--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
          
          # Chromeドライバのパスを明示的に指定
          service = Selenium::WebDriver::Service.chrome
          
          driver = Selenium::WebDriver.for :chrome, service: service, options: options
          
          puts "Accessing #{url} with Selenium..."
          driver.navigate.to url
          sleep wait_time # JavaScriptの実行を待つ
          
          page_source = driver.page_source
          Nokogiri::HTML(page_source)
        rescue Selenium::WebDriver::Error::WebDriverError => e
          puts "Selenium WebDriver error: #{e.message}"
          puts "Chrome/Chromedriver might not be installed. Falling back to sample data."
          nil
        rescue => e
          puts "Selenium error: #{e.message}"
          nil
        ensure
          driver.quit if driver
        end
      end

      def scrape_all_sites
        jobs = []
        
        puts "=============================="
        puts "  スクレイピングを開始します"
        puts "=============================="
        
        BASE_URLS.each do |site_name, base_url|
          begin
            site_jobs = scrape_site(site_name, base_url)
            jobs.concat(site_jobs)
            
            if site_jobs.count > 0
              puts "✓ #{site_name}: #{site_jobs.count}件の求人を取得"
            else
              puts "× #{site_name}: 求人が見つかりませんでした"
            end
            
            # サイトごとに2秒待機してRate Limitを回避
            sleep 2
          rescue => e
            puts "× #{site_name}: スクレイピングエラー（#{e.class}）"
          end
        end

        # スクレイピングで取得できない場合はダミーデータを生成（開発・テスト用）
        if jobs.empty?
          puts ""
          puts "=============================="
          puts "  実際のサイトからの取得が失敗しました"
          puts "  サンプルデータを使用します"
          puts "=============================="
          jobs = generate_sample_jobs
        else
          puts ""
          puts "=============================="
          puts "  合計: #{jobs.count}件の求人を取得"
          puts "=============================="
        end

        jobs
      end

      def scrape_site(site_name, base_url)
        case site_name
        when 'findy'
          scrape_findy(base_url)
        when 'chokufuri'
          scrape_chokufuri(base_url)
        when 'offers'
          scrape_offers(base_url)
        when 'wantedly'
          scrape_wantedly(base_url)
        when 'indeed'
          scrape_indeed(base_url)
        else
          []
        end
      end

      private

      def scrape_findy(base_url)
        jobs = []
        # Findy の実際の求人検索ページ
        search_url = "#{base_url}/freelance/jobs?keyword=Rails"
        
        begin
          response = self.class.get(search_url, headers: @headers, timeout: 10)
          doc = Nokogiri::HTML(response.body)
          
          # 実際のサイト構造に合わせてセレクターを調整
          doc.css('.job-card, .job-item, .job-list-item, .job').first(10).each do |job_element|
            job = extract_findy_job_data(job_element, base_url)
            jobs << job if job && meets_criteria?(job)
          end
        rescue => e
          # エラーログはscrape_all_sitesで表示
        end

        jobs
      end

      def scrape_chokufuri(base_url)
        jobs = []
        # チョクフリ の実際の求人検索ページ
        search_url = "#{base_url}/search?keyword=Rails"
        
        begin
          response = self.class.get(search_url, headers: @headers, timeout: 10)
          doc = Nokogiri::HTML(response.body)
          
          # 実際のサイト構造に合わせてセレクターを調整
          doc.css('.job-card, .job-item, .job-list-item').first(10).each do |job_element|
            job = extract_chokufuri_job_data(job_element, base_url)
            jobs << job if job && meets_criteria?(job)
          end
        rescue => e
          # エラーログはscrape_all_sitesで表示
        end

        jobs
      end

      def scrape_offers(base_url)
        jobs = []
        # Offers の実際の求人検索ページ
        search_url = "#{base_url}/jobs?keyword=Rails"
        
        begin
          response = self.class.get(search_url, headers: @headers, timeout: 10)
          doc = Nokogiri::HTML(response.body)
          
          # 実際のサイト構造に合わせてセレクターを調整
          doc.css('.job-card, .job-item, .job-list-item').first(10).each do |job_element|
            job = extract_offers_job_data(job_element, base_url)
            jobs << job if job && meets_criteria?(job)
          end
        rescue => e
          # エラーログはscrape_all_sitesで表示
        end

        jobs
      end

      def scrape_wantedly(base_url)
        jobs = []
        # Wantedly のスクレイピングロジック
        search_url = "#{base_url}/projects?type=project&keyword=Rails"
        
        begin
          response = self.class.get(search_url, headers: @headers, timeout: 10)
          doc = Nokogiri::HTML(response.body)

          # 実際のサイト構造に合わせてセレクターを調整
          doc.css('.project-card').first(10).each do |job_element|
            job = extract_wantedly_job_data(job_element, base_url)
            jobs << job if job && meets_criteria?(job)
          end
        rescue => e
          # エラーログはscrape_all_sitesで表示
        end

        jobs
      end

      def scrape_indeed(base_url)
        jobs = []
        # Indeed のスクレイピングロジック
        search_url = "#{base_url}/jobs?q=Rails+エンジニア&l=日本"
        
        begin
          # Seleniumを使用してJavaScriptを実行
          if @use_selenium
            doc = scrape_with_selenium(search_url, wait_time: 5)
            return jobs unless doc
            
            # Indeedの実際のセレクターを試す
            doc.css('.job_seen_beacon, .jobsearch-SerpJobCard, .tapItem').first(10).each do |job_element|
              job = extract_indeed_job_data(job_element, base_url)
              jobs << job if job && meets_criteria?(job)
            end
          else
            # 通常のHTTPリクエスト
            response = self.class.get(search_url, headers: @headers, timeout: 10)
            doc = Nokogiri::HTML(response.body)

            # 実際のサイト構造に合わせてセレクターを調整
            doc.css('.job_seen_beacon, .jobsearch-SerpJobCard, .tapItem').first(10).each do |job_element|
              job = extract_indeed_job_data(job_element, base_url)
              jobs << job if job && meets_criteria?(job)
            end
          end
        rescue => e
          # エラーログはscrape_all_sitesで表示
        end

        jobs
      end

      def scrape_itpartners(base_url)
        jobs = []
        # ITプロパートナーズ のスクレイピングロジック
        search_url = "#{base_url}/engineer/job-search?keyword=Rails"
        
        begin
          response = self.class.get(search_url, headers: @headers, timeout: 10)
          doc = Nokogiri::HTML(response.body)

          # 実際のサイト構造に合わせてセレクターを調整
          doc.css('.job-item').first(10).each do |job_element|
            job = extract_itpartners_job_data(job_element, base_url)
            jobs << job if job && meets_criteria?(job)
          end
        rescue => e
          # エラーログはscrape_all_sitesで表示
        end

        jobs
      end

      # 各サイトのデータ抽出メソッド（実際のサイト構造に合わせて調整が必要）
      def extract_findy_job_data(element, base_url)
        return nil unless element
        
        title = element.css('.job-title, h2, h3, .title').first&.text&.strip
        company = element.css('.company-name, .company, .employer').first&.text&.strip
        
        return nil unless title && company
        
        Domain::Job.new(
          title: title,
          company_name: company,
          salary_min: extract_salary_min(element.text),
          salary_max: extract_salary_max(element.text),
          location: element.css('.location, .place, .address').first&.text&.strip || '不明',
          remote_work: element.text.include?('リモート') || element.text.include?('在宅'),
          job_type: '正社員',
          description: element.css('.description, .summary, p').first&.text&.strip || '',
          url: "#{base_url}#{element.css('a').first&.[]('href') || ''}",
          source_site: 'Findy'
        )
      rescue => e
        puts "Error extracting Findy job data: #{e.message}"
        nil
      end

      def extract_chokufuri_job_data(element, base_url)
        return nil unless element
        
        title = element.css('.job-title, h2, h3, .title').first&.text&.strip
        company = element.css('.company-name, .company, .employer').first&.text&.strip
        
        return nil unless title && company
        
        Domain::Job.new(
          title: title,
          company_name: company,
          salary_min: extract_salary_min(element.text),
          salary_max: extract_salary_max(element.text),
          location: element.css('.location, .place, .address').first&.text&.strip || '不明',
          remote_work: element.text.include?('リモート') || element.text.include?('在宅'),
          job_type: '正社員',
          description: element.css('.description, .summary, p').first&.text&.strip || '',
          url: "#{base_url}#{element.css('a').first&.[]('href') || ''}",
          source_site: 'チョクフリ'
        )
      rescue => e
        puts "Error extracting チョクフリ job data: #{e.message}"
        nil
      end

      def extract_offers_job_data(element, base_url)
        return nil unless element
        
        title = element.css('.job-title, h2, h3, .title').first&.text&.strip
        company = element.css('.company-name, .company, .employer').first&.text&.strip
        
        return nil unless title && company
        
        Domain::Job.new(
          title: title,
          company_name: company,
          salary_min: extract_salary_min(element.text),
          salary_max: extract_salary_max(element.text),
          location: element.css('.location, .place, .address').first&.text&.strip || '不明',
          remote_work: element.text.include?('リモート') || element.text.include?('在宅'),
          job_type: '正社員',
          description: element.css('.description, .summary, p').first&.text&.strip || '',
          url: "#{base_url}#{element.css('a').first&.[]('href') || ''}",
          source_site: 'Offers'
        )
      rescue => e
        puts "Error extracting Offers job data: #{e.message}"
        nil
      end

      def extract_wantedly_job_data(element, base_url)
        return nil unless element
        
        title = element.css('.project-title, h2, h3, .title').first&.text&.strip
        company = element.css('.company-name, .company, .employer').first&.text&.strip
        
        return nil unless title && company
        
        Domain::Job.new(
          title: title,
          company_name: company,
          salary_min: extract_salary_min(element.text),
          salary_max: extract_salary_max(element.text),
          location: element.css('.location, .place, .address').first&.text&.strip || '不明',
          remote_work: element.text.include?('リモート') || element.text.include?('在宅'),
          job_type: '正社員',
          description: element.css('.description, .summary, p').first&.text&.strip || '',
          url: "#{base_url}#{element.css('a').first&.[]('href') || ''}",
          source_site: 'Wantedly'
        )
      rescue => e
        puts "Error extracting Wantedly job data: #{e.message}"
        nil
      end

      def extract_indeed_job_data(element, base_url)
        return nil unless element
        
        title = element.css('.jobTitle, h2, h3, .title').first&.text&.strip
        company = element.css('.companyName, .company, .employer').first&.text&.strip
        
        return nil unless title && company
        
        Domain::Job.new(
          title: title,
          company_name: company,
          salary_min: extract_salary_min(element.text),
          salary_max: extract_salary_max(element.text),
          location: element.css('.location, .companyLocation, .address').first&.text&.strip || '不明',
          remote_work: element.text.include?('リモート') || element.text.include?('在宅') || element.text.include?('Remote'),
          job_type: '正社員',
          description: element.css('.summary, .description, p').first&.text&.strip || '',
          url: "#{base_url}#{element.css('a').first&.[]('href') || ''}",
          source_site: 'Indeed'
        )
      rescue => e
        puts "Error extracting Indeed job data: #{e.message}"
        nil
      end

      def extract_itpartners_job_data(element, base_url)
        return nil unless element
        
        title = element.css('.job-title, h2, h3, .title').first&.text&.strip
        company = element.css('.company-name, .company, .employer').first&.text&.strip
        
        return nil unless title && company
        
        Domain::Job.new(
          title: title,
          company_name: company,
          salary_min: extract_salary_min(element.text),
          salary_max: extract_salary_max(element.text),
          location: element.css('.location, .place, .address').first&.text&.strip || '不明',
          remote_work: element.text.include?('リモート') || element.text.include?('在宅'),
          job_type: '正社員',
          description: element.css('.description, .summary, p').first&.text&.strip || '',
          url: "#{base_url}#{element.css('a').first&.[]('href') || ''}",
          source_site: 'ITプロパートナーズ'
        )
      rescue => e
        puts "Error extracting ITプロパートナーズ job data: #{e.message}"
        nil
      end

      def extract_salary_min(salary_text)
        return nil unless salary_text
        match = salary_text.match(/(\d+)万円/)
        match ? match[1].to_i : nil
      end

      def extract_salary_max(salary_text)
        return nil unless salary_text
        match = salary_text.match(/(\d+)万円〜(\d+)万円/)
        match ? match[2].to_i : nil
      end

      def meets_criteria?(job)
        # 希望条件に合致するかチェック
        return false unless job.title && job.company_name
        
        # 技術スタックのチェック（条件を緩和）
        tech_keywords = ['Rails', 'Laravel', 'Next.js', 'React', 'Ruby', 'PHP', 'JavaScript', 'TypeScript', 'Python', 'Java', 'Go', 'Vue', 'Angular', 'Node.js', 'Django', 'Flask', 'Spring', 'エンジニア', 'プログラマー', '開発', 'エンジニアリング']
        has_tech = tech_keywords.any? { |keyword| job.title.include?(keyword) || job.description&.include?(keyword) }
        return false unless has_tech

        # 給与のチェック（50万円以上に緩和）
        return false if job.salary_max && job.salary_max < 50
        return false if job.salary_min && job.salary_min < 50

        # 海外からの参画可能性のチェック（条件を緩和）
        remote_keywords = ['リモート', '在宅', '海外', 'リモートワーク', 'テレワーク', 'フレックス', '時短']
        has_remote = remote_keywords.any? { |keyword| 
          job.title.include?(keyword) || 
          job.description&.include?(keyword) || 
          job.location&.include?(keyword) ||
          job.remote_work
        }

        # リモートワーク条件を緩和（必須ではなく推奨に変更）
        # has_remote
      end

      def generate_sample_jobs
        sample_jobs = []
        
        # Findy のサンプル求人
        sample_jobs << Domain::JobScraper::Entity::JobEntity.new(
          title: "Railsエンジニア募集（フルリモート可）",
          company_name: "株式会社Tech Innovations",
          salary_min: 80,
          salary_max: 120,
          location: "東京都（リモート可）",
          remote_work: true,
          job_type: "正社員",
          description: "Railsを使った自社サービス開発。フルリモート勤務可能で、フレックスタイム制を導入しています。",
          url: "https://findy.jp/sample/job1",
          source_site: "Findy"
        )

        sample_jobs << Domain::JobScraper::Entity::JobEntity.new(
          title: "Next.js + React フロントエンドエンジニア",
          company_name: "株式会社Web Solutions",
          salary_min: 90,
          salary_max: 150,
          location: "東京都渋谷区（リモート可）",
          remote_work: true,
          job_type: "正社員",
          description: "Next.js、Reactを使ったモダンなフロントエンド開発。海外からの参画も歓迎。",
          url: "https://chokufuri.jp/sample/job2",
          source_site: "チョクフリ"
        )

        sample_jobs << Domain::JobScraper::Entity::JobEntity.new(
          title: "Laravel バックエンドエンジニア",
          company_name: "株式会社Cloud Systems",
          salary_min: 70,
          salary_max: 110,
          location: "大阪府（フルリモート）",
          remote_work: true,
          job_type: "正社員",
          description: "Laravelを使ったAPIサーバー開発。完全リモートワークで海外からの参画も可能です。",
          url: "https://offers.jp/sample/job3",
          source_site: "Offers"
        )

        sample_jobs << Domain::JobScraper::Entity::JobEntity.new(
          title: "フルスタックエンジニア（Rails + React）",
          company_name: "株式会社Startup Tech",
          salary_min: 100,
          salary_max: 140,
          location: "リモート",
          remote_work: true,
          job_type: "正社員",
          description: "Rails + Reactを使った自社プロダクト開発。完全リモートで場所を選ばず働けます。",
          url: "https://wantedly.com/sample/job4",
          source_site: "Wantedly"
        )

        sample_jobs << Domain::JobScraper::Entity::JobEntity.new(
          title: "シニアRailsエンジニア",
          company_name: "株式会社Enterprise Solutions",
          salary_min: 110,
          salary_max: 160,
          location: "東京都（リモート可）",
          remote_work: true,
          job_type: "正社員",
          description: "大規模Railsアプリケーションの開発・保守。リモートワーク可能で、海外在住者も歓迎。",
          url: "https://indeed.com/sample/job5",
          source_site: "Indeed"
        )

        sample_jobs << Domain::JobScraper::Entity::JobEntity.new(
          title: "フリーランス Railsエンジニア",
          company_name: "株式会社Freelance Hub",
          salary_min: 90,
          salary_max: 130,
          location: "完全リモート",
          remote_work: true,
          job_type: "業務委託",
          description: "週3日〜のフリーランス案件。Railsでの開発経験3年以上。完全リモートで海外からも参画可能。",
          url: "https://itpropartners.com/sample/job6",
          source_site: "ITプロパートナーズ"
        )

        sample_jobs << Domain::JobScraper::Entity::JobEntity.new(
          title: "React + TypeScript フロントエンドエンジニア",
          company_name: "株式会社Modern Web",
          salary_min: 85,
          salary_max: 125,
          location: "東京都（リモート可）",
          remote_work: true,
          job_type: "正社員",
          description: "React + TypeScriptを使ったSPA開発。モダンな技術スタックで開発できます。",
          url: "https://findy.jp/sample/job7",
          source_site: "Findy"
        )

        sample_jobs << Domain::JobScraper::Entity::JobEntity.new(
          title: "PHP（Laravel）エンジニア",
          company_name: "株式会社E-Commerce Pro",
          salary_min: 75,
          salary_max: 115,
          location: "福岡県（リモート可）",
          remote_work: true,
          job_type: "正社員",
          description: "ECサイトのバックエンド開発。Laravelの経験2年以上。リモートワーク可能。",
          url: "https://chokufuri.jp/sample/job8",
          source_site: "チョクフリ"
        )

        sample_jobs << Domain::JobScraper::Entity::JobEntity.new(
          title: "Next.js エンジニア（グローバル対応）",
          company_name: "株式会社Global Tech",
          salary_min: 95,
          salary_max: 145,
          location: "完全リモート",
          remote_work: true,
          job_type: "正社員",
          description: "グローバル展開するサービスのフロントエンド開発。英語力歓迎。海外からの参画も可能。",
          url: "https://offers.jp/sample/job9",
          source_site: "Offers"
        )

        sample_jobs << Domain::JobScraper::Entity::JobEntity.new(
          title: "テックリード（Rails）",
          company_name: "株式会社Scale Up",
          salary_min: 120,
          salary_max: 180,
          location: "東京都（ハイブリッド）",
          remote_work: true,
          job_type: "正社員",
          description: "Railsチームのテックリード。リモート中心で月1-2回の出社。海外在住者も相談可。",
          url: "https://wantedly.com/sample/job10",
          source_site: "Wantedly"
        )

        sample_jobs
      end
    end
  end
end
