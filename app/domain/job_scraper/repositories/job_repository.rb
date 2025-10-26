# ドメイン層（リポジトリインターフェース）: 永続化に関するインターフェースを定義する抽象クラス
module Domain
  module Repository
    module JobScraper
      class JobRepository
        def find_all
          raise NotImplementedError, "Subclasses must implement find_all"
        end

        def find_by_id(id)
          raise NotImplementedError, "Subclasses must implement find_by_id"
        end

        def save(job)
          raise NotImplementedError, "Subclasses must implement save"
        end

        def delete(id)
          raise NotImplementedError, "Subclasses must implement delete"
        end

        def find_by_criteria(criteria)
          raise NotImplementedError, "Subclasses must implement find_by_criteria"
        end
      end
    end
  end
end

