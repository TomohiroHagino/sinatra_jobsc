require 'spec_helper'

RSpec.describe Domain::JobScraper::ValueObject::SalaryRange do
  describe '#initialize' do
    it '最小給与と最大給与を設定できる' do
      salary_range = described_class.new(min: 80, max: 120)
      expect(salary_range.min).to eq(80)
      expect(salary_range.max).to eq(120)
    end
  end

  describe '#to_s' do
    context '最小と最大が設定されている場合' do
      it '範囲の文字列を返す' do
        salary_range = described_class.new(min: 80, max: 120)
        expect(salary_range.to_s).to eq('80万円〜120万円')
      end
    end

    context '最小のみ設定されている場合' do
      it '最小値のみの文字列を返す' do
        salary_range = described_class.new(min: 80)
        expect(salary_range.to_s).to eq('80万円〜')
      end
    end

    context '最大のみ設定されている場合' do
      it '最大値のみの文字列を返す' do
        salary_range = described_class.new(max: 120)
        expect(salary_range.to_s).to eq('120万円以下')
      end
    end

    context '両方nilの場合' do
      it '要相談を返す' do
        salary_range = described_class.new
        expect(salary_range.to_s).to eq('要相談')
      end
    end
  end

  describe '#includes?' do
    it '金額が範囲内の場合はtrueを返す' do
      salary_range = described_class.new(min: 80, max: 120)
      expect(salary_range.includes?(100)).to be true
    end

    it '金額が範囲外の場合はfalseを返す' do
      salary_range = described_class.new(min: 80, max: 120)
      expect(salary_range.includes?(150)).to be false
    end

    it '最小のみの場合、最小以上であればtrueを返す' do
      salary_range = described_class.new(min: 80)
      expect(salary_range.includes?(80)).to be true
      expect(salary_range.includes?(100)).to be true
      expect(salary_range.includes?(70)).to be false
    end

    it '最大のみの場合、最大以下であればtrueを返す' do
      salary_range = described_class.new(max: 120)
      expect(salary_range.includes?(120)).to be true
      expect(salary_range.includes?(100)).to be true
      expect(salary_range.includes?(150)).to be false
    end
  end
end

