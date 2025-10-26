require 'spec_helper'

RSpec.describe Application::UseCase::JobScraper::DeleteJobUseCase do
  let(:repository) { Infrastructure::Repository::ActiveRecordJobRepository.new }
  let(:use_case) { described_class.new(repository) }

  describe '#execute' do
    let!(:saved_job) { create(:saved_job) }

    context '存在する求人IDの場合' do
      it '求人を削除する' do
        expect {
          result = use_case.execute(saved_job.id)
          expect(result[:success]).to be true
        }.to change { Infrastructure::Model::SavedJob.count }.by(-1)
      end
    end

    context '存在しない求人IDの場合' do
      it 'エラーを返す' do
        result = use_case.execute(99999)
        expect(result[:success]).to be false
        expect(result[:errors]).to include('求人情報が見つかりません')
      end
    end
  end
end

