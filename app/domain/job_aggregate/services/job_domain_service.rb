# ドメイン層（サービス）: 複数のエンティティにまたがるビジネスロジックを実装するドメインサービス
module Domain
  module Service
    module JobAggregate
      class JobDomainService
        def initialize(job_repository)
          @job_repository = job_repository
        end
      
        def meets_salary_criteria?(job, min_salary)
          return true unless min_salary
          
          job.salary_min && job.salary_min >= min_salary ||
          job.salary_max && job.salary_max >= min_salary
        end
      
        def meets_remote_criteria?(job)
          job.remote_work || 
          job.location&.include?('リモート') ||
          job.location&.include?('在宅') ||
          job.description&.include?('リモート') ||
          job.description&.include?('在宅')
        end
      
        def meets_tech_stack_criteria?(job)
          tech_keywords = ['Rails', 'Laravel', 'Next.js', 'React', 'Ruby', 'PHP', 'JavaScript', 'TypeScript']
          tech_keywords.any? do |keyword|
            job.title&.include?(keyword) || 
            job.description&.include?(keyword)
          end
        end
      
        def filter_jobs_by_criteria(jobs, criteria)
          jobs.select do |job|
            meets_salary_criteria?(job, criteria[:min_salary]) &&
            (!criteria[:remote_only] || meets_remote_criteria?(job)) &&
            meets_tech_stack_criteria?(job)
          end
        end
      
        def calculate_average_salary(jobs)
          return 0 if jobs.empty?
          
          total_salary = jobs.sum do |job|
            if job.salary_min && job.salary_max
              (job.salary_min + job.salary_max) / 2
            elsif job.salary_min
              job.salary_min
            elsif job.salary_max
              job.salary_max
            else
              0
            end
          end
          
          total_salary / jobs.count
        end
      
        def get_salary_statistics(jobs)
          salaries = jobs.map do |job|
            if job.salary_min && job.salary_max
              (job.salary_min + job.salary_max) / 2
            elsif job.salary_min
              job.salary_min
            elsif job.salary_max
              job.salary_max
            end
          end.compact
      
          return {} if salaries.empty?
      
          {
            min: salaries.min,
            max: salaries.max,
            average: salaries.sum / salaries.count,
            median: calculate_median(salaries)
          }
        end
      
        private
      
        def calculate_median(salaries)
          sorted = salaries.sort
          len = sorted.length
          (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
        end
      end
    end
  end
end
