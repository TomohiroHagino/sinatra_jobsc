require 'spec_helper'

RSpec.describe Infrastructure::Repository::ActiveRecordJobRepository do
  let(:repository) { described_class.new }

  describe '#find_all' do
    let!(:active_job) { create(:saved_job) }
    let!(:inactive_job) { create(:saved_job, :inactive) }

    it 'アクティブな求人のみを返す' do
      jobs = repository.find_all
      expect(jobs.length).to eq(1)
      expect(jobs.first).to be_a(Domain::JobScraper::Entity::SavedJobEntity)
      expect(jobs.first.title).to eq(active_job.title)
    end
  end

  describe '#find_by_id' do
    let!(:saved_job) { create(:saved_job) }

    context '存在する求人IDの場合' do
      it '求人エンティティを返す' do
        job = repository.find_by_id(saved_job.id)
        expect(job).to be_a(Domain::JobScraper::Entity::SavedJobEntity)
        expect(job.id).to eq(saved_job.id)
      end
    end

    context '存在しない求人IDの場合' do
      it 'nilを返す' do
        job = repository.find_by_id(99999)
        expect(job).to be_nil
      end
    end
  end

  describe '#save' do
    context '新規求人の場合' do
      let(:job_entity) do
        Domain::JobScraper::Entity::JobEntity.new(
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
        )
      end

      it '求人を保存する' do
        expect {
          saved_job = repository.save(job_entity)
          expect(saved_job).to be_a(Domain::JobScraper::Entity::SavedJobEntity)
          expect(saved_job.id).not_to be_nil
        }.to change { Infrastructure::Model::SavedJob.count }.by(1)
      end
    end

    context '既存求人の更新の場合' do
      let!(:existing_job) { create(:saved_job) }
      let(:updated_entity) do
        Domain::JobScraper::Entity::SavedJobEntity.new(
          id: existing_job.id,
          title: '更新されたタイトル',
          company_name: existing_job.company_name,
          url: existing_job.url,
          source_site: existing_job.source_site,
          is_active: true,
          created_at: existing_job.created_at,
          updated_at: existing_job.updated_at
        )
      end

      it '既存の求人を更新する' do
        expect {
          repository.save(updated_entity)
        }.not_to change { Infrastructure::Model::SavedJob.count }

        updated_job = Infrastructure::Model::SavedJob.find(existing_job.id)
        expect(updated_job.title).to eq('更新されたタイトル')
      end
    end
  end

  describe '#delete' do
    let!(:saved_job) { create(:saved_job) }

    it '求人を削除する' do
      expect {
        repository.delete(saved_job.id)
      }.to change { Infrastructure::Model::SavedJob.count }.by(-1)
    end
  end

  describe '#find_by_criteria' do
    let!(:high_salary_remote) do
      create(:saved_job, :high_salary, 
             title: 'シニアエンジニア', 
             company_name: 'A社',
             remote_work: true)
    end
    let!(:regular_onsite) do
      create(:saved_job, :no_remote,
             title: 'ジュニアエンジニア',
             company_name: 'B社',
             salary_min: 60,
             salary_max: 80)
    end

    it '最低給与でフィルタリングできる' do
      jobs = repository.find_by_criteria(min_salary: 100)
      expect(jobs.length).to eq(1)
      expect(jobs.first.title).to eq('シニアエンジニア')
    end

    it 'リモート勤務でフィルタリングできる' do
      jobs = repository.find_by_criteria(remote_only: true)
      expect(jobs.length).to eq(1)
      expect(jobs.first.remote_work).to be true
    end

    it '会社名で検索できる' do
      jobs = repository.find_by_criteria(company: 'A社')
      expect(jobs.length).to eq(1)
      expect(jobs.first.company_name).to eq('A社')
    end

    it 'タイトルで検索できる' do
      jobs = repository.find_by_criteria(title: 'シニア')
      expect(jobs.length).to eq(1)
      expect(jobs.first.title).to include('シニア')
    end

    it '複数条件で検索できる' do
      jobs = repository.find_by_criteria(
        min_salary: 100,
        remote_only: true,
        company: 'A社'
      )
      expect(jobs.length).to eq(1)
      expect(jobs.first.title).to eq('シニアエンジニア')
    end
  end
end

