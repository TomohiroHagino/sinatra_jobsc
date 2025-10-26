# ドメイン層（エンティティ）: 永続化された求人情報を表現するエンティティ。フレームワーク非依存
module Domain
  module JobAggregate
    module Entity
      class SavedJobEntity
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
        attribute :created_at, :datetime
        attribute :updated_at, :datetime

        validates :title, presence: true
        validates :company_name, presence: true
        validates :url, presence: true
        validates :source_site, presence: true

        def salary_range
          return "#{salary_min}万円〜" if salary_min && !salary_max
          return "#{salary_max}万円以下" if salary_max && !salary_min
          return "#{salary_min}万円〜#{salary_max}万円" if salary_min && salary_max
          "要相談"
        end

        def remote_work_text
          remote_work ? "リモート可" : "出社必要"
        end

        def active?
          is_active
        end

        def to_job
          Domain::JobAggregate::Entity::JobEntity.new(
            id: id,
            title: title,
            company_name: company_name,
            salary_min: salary_min,
            salary_max: salary_max,
            location: location,
            remote_work: remote_work,
            job_type: job_type,
            description: description,
            url: url,
            source_site: source_site,
            is_active: is_active,
            created_at: created_at,
            updated_at: updated_at
          )
        end
      end
    end
  end
end

