require 'spec_helper'

RSpec.describe 'Jobs API', type: :request do
  def app
    Presentation::Controller::JobsController
  end

  describe 'GET /' do
    context '保存された求人がある場合' do
      let!(:saved_job) { create(:saved_job) }

      it 'ステータス200を返す' do
        get '/'
        expect(last_response).to be_ok
      end

      it '保存された求人情報を表示する' do
        get '/'
        expect(last_response.body).to include('保存された求人情報')
        expect(last_response.body).to include(saved_job.title)
      end
    end

    context '保存された求人がない場合' do
      it '空の状態を表示する' do
        get '/'
        expect(last_response).to be_ok
        expect(last_response.body).to include('保存された求人情報がありません')
      end
    end
  end

  describe 'POST /jobs' do
    let(:valid_job_params) do
      {
        job: {
          title: 'テスト求人',
          company_name: 'テスト株式会社',
          salary_min: 80,
          salary_max: 120,
          location: '東京都',
          remote_work: true,
          job_type: '正社員',
          description: 'テスト用の求人です',
          url: 'https://example.com/job/test',
          source_site: 'テストサイト',
          is_active: true
        }
      }
    end

    it '求人を保存してリダイレクトする' do
      expect {
        post '/jobs', valid_job_params
      }.to change { Infrastructure::Model::SavedJob.count }.by(1)

      expect(last_response.status).to eq(302)
      expect(last_response.location).to include('/?saved=true')
    end

    context '無効なパラメータの場合' do
      let(:invalid_job_params) do
        { job: { title: '' } }
      end

      it 'エラーを表示する' do
        post '/jobs', invalid_job_params
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('エラーが発生しました')
      end
    end
  end

  describe 'DELETE /jobs/:id' do
    let!(:saved_job) { create(:saved_job) }

    it '求人を削除してリダイレクトする' do
      expect {
        delete "/jobs/#{saved_job.id}"
      }.to change { Infrastructure::Model::SavedJob.count }.by(-1)

      expect(last_response.status).to eq(302)
      expect(last_response.location).to include('/?deleted=true')
    end
  end

  describe 'GET /search' do
    let!(:high_salary_job) { create(:saved_job, :high_salary, title: 'シニアエンジニア') }
    let!(:regular_job) { create(:saved_job, title: 'ジュニアエンジニア') }

    it '検索結果を表示する' do
      get '/search', { min_salary: 100 }
      expect(last_response).to be_ok
    end

    it '最低給与でフィルタリングできる' do
      get '/search', { min_salary: 100 }
      expect(last_response.body).to include('シニアエンジニア')
    end
  end
end

