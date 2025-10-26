module Domain
  module JobScraper
    module Entity
      class JobEntity
        include ActiveModel::Model
        include ActiveModel::Attributes

        attribute :id, :integer
        attribute :title, :string
        attribute :company_name, :string
        attribute :salary_min, :integer
        attribute :salary_max, :integer
        attribute :location, :string
        attribute :remote_work, :boolean, default: false
        attribute :job_type, :string
        attribute :description, :string
        attribute :url, :string
        attribute :source_site, :string
        attribute :is_active, :boolean, default: true
        attribute :posted_at, :datetime
        attribute :created_at, :datetime
        attribute :updated_at, :datetime

        validates :title, :company_name, :url, :source_site, presence: true
        validates :salary_min, numericality: { allow_nil: true }
        validates :salary_max, numericality: { allow_nil: true }
        validate  :salary_range_consistency

        def salary_range_consistency
          return if salary_min.nil? || salary_max.nil?
          errors.add(:base, 'salary_min は salary_max 以下である必要があります') if salary_min > salary_max
        end

        def salary_range
          return "#{salary_min}万円〜"       if salary_min && !salary_max
          return "#{salary_max}万円以下"      if salary_max && !salary_min
          return "#{salary_min}万円〜#{salary_max}万円" if salary_min && salary_max
          "要相談"
        end

        def remote_work_text
          remote_work ? "リモート可" : "出社必要"
        end

        def active?
          is_active
        end

        def to_saved_job
          SavedJobEntity.new(
            title: title,
            company_name: company_name,
            salary_min: salary_min,
            salary_max: salary_max,
            location: location,
            remote_work: remote_work,
            job_type: job_type,
            description: description,
            url: url,
            source_site: source_site
          )
        end
      end
    end
  end
end
