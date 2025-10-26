require 'spec_helper'

RSpec.describe Application::UseCase::JobScraper::SaveJobUseCase do
  let(:repository) { Infrastructure::Repository::ActiveRecordJobRepository.new }
  let(:use_case) { described_class.new(repository) }

  describe '#execute' do
    context '有効な求人情報の場合' do
      let(:job_params) do
        {
          title: 'Railsエンジニア',
          company_name: 'テスト株式会社',
          salary_min: 80,
          salary_max: 120,
          location: '東京都',
          remote_work: true,
          job_type: '正社員',
          description: 'テスト用',
          url: 'https://example.com/job/1',
          source_site: 'テストサイト',
          is_active: true
        }
      end

      it '求人を保存する' do
        expect {
          result = use_case.execute(job_params)
          expect(result[:success]).to be true
        }.to change { Infrastructure::Model::SavedJob.count }.by(1)
      end

      it '保存された求人エンティティを返す' do
        result = use_case.execute(job_params)
        expect(result[:job]).to be_a(Domain::JobScraper::Entity::SavedJobEntity)
        expect(result[:job].title).to eq('Railsエンジニア')
      end
    end

    context '無効な求人情報の場合' do
      let(:invalid_params) do
        {
          title: '',
          company_name: '',
          url: '',
          source_site: ''
        }
      end

      it 'エラーを返す' do
        result = use_case.execute(invalid_params)
        expect(result[:success]).to be false
        expect(result[:errors]).not_to be_empty
      end
    end
  end
end

