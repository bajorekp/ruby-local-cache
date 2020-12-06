# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LocalCache do
  subject(:cache) { described_class.new(logger: logger) }

  let(:logger) { instance_double(Logger, debug: nil) }

  describe '.write' do
    it 'saves entry' do
      cached_value = double('cached_value')
      expect(cache.write('foo', cached_value)).to eq(cached_value)
    end

    it 'overwrites entry' do
      cached_value = double('cached_value')
      expect(cache.write('foo', cached_value)).to eq(cached_value)
      new_cached_value = double('new_cached_value')
      expect(cache.write('foo', new_cached_value)).to eq(new_cached_value)
    end
  end

  describe '.valid?' do
    it 'returns false for unknown entry' do
      expect(cache).not_to be_valid('foo')
    end

    it 'returns true for cached entry' do
      cached_value = double('cached_value')
      expect(cache.write('foo', cached_value)).to eq(cached_value)
      expect(cache).to be_valid('foo')
    end

    it 'returns false value for expired entry' do
      cached_value = double('cached_value')
      expect(cache.write('foo', cached_value, expires_in_seconds: 10)).to eq(cached_value)
      allow(Time).to receive(:now).and_return(Time.now + 11)
      expect(cache).not_to be_valid('foo')
    end
  end

  describe '.read' do
    it 'returns nil for unknown entry' do
      expect(cache.read('foo')).to eq(nil)
    end

    it 'returns a cached value for the cached entry' do
      cached_value = double('cached_value')
      expect(cache.write('foo', cached_value)).to eq(cached_value)
      expect(cache.read('foo')).to eq(cached_value)
    end

    it 'returns nil value for expired entry' do
      cached_value = double('cached_value')
      expect(cache.write('foo', cached_value, expires_in_seconds: 10)).to eq(cached_value)
      allow(Time).to receive(:now).and_return(Time.now + 11)
      expect(cache.read('foo')).to eq(nil)
    end
  end

  describe '.fetch' do
    it 'returns block result for unknown entry' do
      first_block_execution_result = double('first_block_execution_result')
      expect(cache.fetch('foo') { first_block_execution_result }).to eq(first_block_execution_result)
    end

    it 'returns a cached value for the cached entry' do
      cached_value = double('cached_value')
      expect(cache.write('foo', cached_value)).to eq(cached_value)
      first_block_execution_result = double('first_block_execution_result')
      expect(cache.fetch('foo') { first_block_execution_result }).to eq(cached_value)
    end

    it 'returns block result value for expired entry' do
      cached_value = double('cached_value')
      expect(cache.write('foo', cached_value, expires_in_seconds: 10)).to eq(cached_value)

      allow(Time).to receive(:now).and_return(Time.now + 11)

      first_block_result = double('first_block_result')
      expect(cache.fetch('foo') { first_block_result }).to eq(first_block_result)
    end

    it 'saves new entry' do
      first_block_result = double('first_block_result')
      expect(cache.fetch('foo') { first_block_result }).to eq(first_block_result)

      expect(cache.read('foo')).to eq(first_block_result)
      expect(cache.fetch('foo') { first_block_result }).to eq(first_block_result)
    end

    it "don't overwrite a cached entry" do
      first_block_result = double('first_block_result')
      expect(cache.fetch('foo') { block_result }).to eq(first_block_result)
      expect(cache.read('foo')).to eq(first_block_result)

      future_block_result = double('future_block_result')
      expect(cache.fetch('foo') { future_block_result }).to eq(first_block_result)
      expect(cache.read('foo')).to eq(first_block_result)
    end

    it "don't cache nil result" do
      first_block_result = nil
      expect(cache.fetch('foo') { first_block_result }).to eq(first_block_result)

      future_block_result = double('future_block_result')
      expect(cache.fetch('foo') { future_block_result }).to eq(future_block_result)
      expect(cache.read('foo')).to eq(future_block_result)
    end

    context 'with save_nil: true' do
      it 'caches nil result' do
        first_block_result = nil
        expect(cache.fetch('foo', save_nil: true) { first_block_result }).to eq(first_block_result)
        expect(cache.read('foo')).to eq(nil)

        future_block_result = double('future_block_result')
        expect(cache.fetch('foo', save_nil: true) { future_block_result }).to eq(first_block_result)
        expect(cache.read('foo')).to eq(first_block_result)
      end
    end
  end
end
