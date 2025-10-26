require 'spec_helper'

RSpec.describe Domain::JobScraper::Entity::JobEntity do
  describe '#initialize' do
    let(:job_attributes) do
      {
        title: 'Railsエンジニア',
        company_name: 'テスト株式会社',
        salary_min: 80,
        salary_max: 120,
        location: '東京都',
        remote_work: true,
        job_type: '正社員',
        description: 'テスト用の求人',
        url: 'https://example.com/job/1',
        source_site: 'テストサイト',
        is_active: true
      }
    end

    it 'JobEntityインスタンスを作成できる' do
      job = described_class.new(job_attributes)
      
      expect(job.title).to eq('Railsエンジニア')
      expect(job.company_name).to eq('テスト株式会社')
      expect(job.salary_min).to eq(80)
      expect(job.salary_max).to eq(120)
      expect(job.remote_work).to be true
    end
  end

  describe '#salary_range' do
    context '給与範囲が両方設定されている場合' do
      let(:job) do
        described_class.new(
          title: 'Test',
          company_name: 'Test',
          salary_min: 80,
          salary_max: 120,
          url: 'https://example.com',
          source_site: 'test'
        )
      end

      it '給与範囲の文字列を返す' do
        expect(job.salary_range).to eq('80万円〜120万円')
      end
    end

    context '給与範囲が設定されていない場合' do
      let(:job) do
        described_class.new(
          title: 'Test',
          company_name: 'Test',
          url: 'https://example.com',
          source_site: 'test'
        )
      end

      it '要相談を返す' do
        expect(job.salary_range).to eq('要相談')
      end
    end
  end

  describe '#remote_work_text' do
    it 'リモート可の場合は"リモート可"を返す' do
      job = described_class.new(
        title: 'Test',
        company_name: 'Test',
        remote_work: true,
        url: 'https://example.com',
        source_site: 'test'
      )
      expect(job.remote_work_text).to eq('リモート可')
    end

    it 'リモート不可の場合は"出社必要"を返す' do
      job = described_class.new(
        title: 'Test',
        company_name: 'Test',
        remote_work: false,
        url: 'https://example.com',
        source_site: 'test'
      )
      expect(job.remote_work_text).to eq('出社必要')
    end
  end
end

