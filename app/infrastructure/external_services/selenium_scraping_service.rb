# インフラ層（外部サービス）: Seleniumを使ったJavaScriptレンダリング対応のスクレイピングサービス
require 'selenium-webdriver'
require 'nokogiri'

module Infrastructure
  module ExternalService
    class SeleniumScrapingService
      def initialize
        @options = Selenium::WebDriver::Chrome::Options.new
        @options.add_argument('--headless') # ヘッドレスモード
        @options.add_argument('--disable-gpu')
        @options.add_argument('--no-sandbox')
        @options.add_argument('--disable-dev-shm-usage')
        @options.add_argument('--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36')
      end
    
      def scrape_with_selenium(url, wait_time: 5)
        driver = Selenium::WebDriver.for :chrome, options: @options
        
        begin
          driver.navigate.to url
          sleep wait_time # JavaScriptの実行を待つ
          
          page_source = driver.page_source
          Nokogiri::HTML(page_source)
        rescue => e
          puts "Selenium error: #{e.message}"
          nil
        ensure
          driver.quit if driver
        end
      end
    
      def scrape_findy_with_selenium
        jobs = []
        url = "https://findy.jp/freelance/jobs?keyword=Rails"
        
        doc = scrape_with_selenium(url)
        return jobs unless doc
        
        doc.css('.job-card, article, .job-item').first(10).each do |element|
          job = extract_job_data(element, 'Findy', url)
          jobs << job if job
        end
        
        jobs
      end
    
      def scrape_indeed_with_selenium
        jobs = []
        url = "https://jp.indeed.com/jobs?q=Rails+エンジニア&l=日本"
        
        doc = scrape_with_selenium(url)
        return jobs unless doc
        
        doc.css('.job_seen_beacon, .jobsearch-SerpJobCard').first(10).each do |element|
          job = extract_job_data(element, 'Indeed', url)
          jobs << job if job
        end
        
        jobs
      end
    
      private
    
      def extract_job_data(element, source_site, base_url)
        return nil unless element
        
        title = element.css('h2, h3, .title, .jobTitle').first&.text&.strip
        company = element.css('.company, .companyName, .employer').first&.text&.strip
        
        return nil unless title && company
        
        Job.new(
          title: title,
          company_name: company,
          salary_min: extract_salary_min(element.text),
          salary_max: extract_salary_max(element.text),
          location: element.css('.location, .companyLocation').first&.text&.strip || 'リモート',
          remote_work: true,
          job_type: '正社員',
          description: element.css('.description, .summary, p').first&.text&.strip || title,
          url: base_url,
          source_site: source_site
        )
      rescue => e
        puts "Error extracting #{source_site} job data: #{e.message}"
        nil
      end
    
      def extract_salary_min(text)
        return nil unless text
        match = text.match(/(\d+)万円/)
        match ? match[1].to_i : nil
      end
    
      def extract_salary_max(text)
        return nil unless text
        match = text.match(/(\d+)万円〜(\d+)万円/)
        match ? match[2].to_i : nil
      end
    end

  end
end
