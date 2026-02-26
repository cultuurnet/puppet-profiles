require 'spec_helper'
require_relative '../../lib/puppet/functions/hiera_vault/stringify_keys'

describe 'stringify_keys function' do
  describe 'with String input' do
    it 'returns the string unchanged' do
      expect(stringify_keys('hello')).to eq('hello')
    end

    it 'raises error for empty string' do
      expect { stringify_keys('') }.to raise_error(ArgumentError, "Empty or blank string value found: ''")
    end

  end

  describe 'with nil and empty values' do
    it 'raises error for nil input' do
      expect { stringify_keys(nil) }.to raise_error(ArgumentError, "Nil value found")
    end

    it 'raises error for hash with nil values' do
      input = { :key1 => nil, 'key2' => 'value' }
      expect { stringify_keys(input) }.to raise_error(ArgumentError, "Nil value found for key 'key1'")
    end

    it 'raises error for hash with empty string values' do
      input = { :key1 => '', 'key2' => 'value' }
      expect { stringify_keys(input) }.to raise_error(ArgumentError, "Empty or blank string value found: ''")
    end

    it 'raises error for hash with whitespace-only string values' do
      input = { :key1 => '   ', 'key2' => 'value' }
      expect { stringify_keys(input) }.to raise_error(ArgumentError, "Empty or blank string value found: '   '")
    end

    it 'raises error for array with nil values' do
      input = [nil, 'value', 'other']
      expect { stringify_keys(input) }.to raise_error(ArgumentError, "Nil value found")
    end

    it 'raises error for array with empty strings' do
      input = ['', 'value', 'other']
      expect { stringify_keys(input) }.to raise_error(ArgumentError, "Empty or blank string value found: ''")
    end

    it 'raises error for empty string input' do
      expect { stringify_keys('') }.to raise_error(ArgumentError, "Empty or blank string value found: ''")
    end

    it 'raises error for whitespace-only string input' do
      expect { stringify_keys('   ') }.to raise_error(ArgumentError, "Empty or blank string value found: '   '")
    end

    it 'raises error for nested empty hash' do
      input = { 'key' => 'value', 'nested' => {} }
      expect { stringify_keys(input) }.to raise_error(ArgumentError, "Empty hash found")
    end

    it 'raises error for nested empty array' do
      input = { 'key' => 'value', 'list' => [] }
      expect { stringify_keys(input) }.to raise_error(ArgumentError, "Empty array found")
    end

    it 'raises error for array containing empty hash' do
      input = ['value', {}]
      expect { stringify_keys(input) }.to raise_error(ArgumentError, "Empty hash found")
    end

    it 'raises error for array containing empty array' do
      input = ['value', []]
      expect { stringify_keys(input) }.to raise_error(ArgumentError, "Empty array found")
    end
  end

  describe 'with Hash input' do
    it 'converts symbol keys to string keys' do
      input = { :key1 => 'value1', :key2 => 'value2' }
      expected = { 'key1' => 'value1', 'key2' => 'value2' }
      expect(stringify_keys(input)).to eq(expected)
    end

    it 'leaves string keys as strings' do
      input = { 'key1' => 'value1', 'key2' => 'value2' }
      expected = { 'key1' => 'value1', 'key2' => 'value2' }
      expect(stringify_keys(input)).to eq(expected)
    end

    it 'converts mixed key types to strings' do
      input = { :symbol_key => 'value1', 'string_key' => 'value2', 123 => 'value3' }
      expected = { 'symbol_key' => 'value1', 'string_key' => 'value2', '123' => 'value3' }
      expect(stringify_keys(input)).to eq(expected)
    end

    it 'raises error for empty hash' do
      expect { stringify_keys({}) }.to raise_error(ArgumentError, "Empty hash found")
    end

    it 'recursively processes nested hashes' do
      input = { 
        :outer_key => { 
          :inner_key1 => 'value1', 
          'inner_key2' => 'value2' 
        } 
      }
      expected = { 
        'outer_key' => { 
          'inner_key1' => 'value1', 
          'inner_key2' => 'value2' 
        } 
      }
      expect(stringify_keys(input)).to eq(expected)
    end

    it 'processes hash values that are arrays' do
      input = { :key => [:symbol1, 'string1', { :nested => 'value' }] }
      expected = { 'key' => [:symbol1, 'string1', { 'nested' => 'value' }] }
      expect(stringify_keys(input)).to eq(expected)
    end
  end

  describe 'with Array input' do
    it 'processes string elements unchanged' do
      input = ['string1', 'string2', 'string3']
      expected = ['string1', 'string2', 'string3']
      expect(stringify_keys(input)).to eq(expected)
    end

    it 'recursively processes hash elements in array' do
      input = [{ :key1 => 'value1' }, { :key2 => 'value2' }]
      expected = [{ 'key1' => 'value1' }, { 'key2' => 'value2' }]
      expect(stringify_keys(input)).to eq(expected)
    end

    it 'handles nested arrays' do
      input = [['inner1', 'inner2'], [{ :key => 'value' }]]
      expected = [['inner1', 'inner2'], [{ 'key' => 'value' }]]
      expect(stringify_keys(input)).to eq(expected)
    end

    it 'raises error for empty array' do
      expect { stringify_keys([]) }.to raise_error(ArgumentError, "Empty array found")
    end

    it 'processes mixed types in array' do
      input = ['string', 123, { :key => 'value' }, [:symbol]]
      expected = ['string', '123', { 'key' => 'value' }, [:symbol]]
      expect(stringify_keys(input)).to eq(expected)
    end
  end

  describe 'with other data types' do
    it 'converts integers to strings' do
      expect(stringify_keys(123)).to eq('123')
    end

    it 'converts zero to string' do
      expect(stringify_keys(0)).to eq('0')
    end

    it 'converts floats to strings' do
      expect(stringify_keys(12.34)).to eq('12.34')
    end

    it 'converts boolean true to string' do
      expect(stringify_keys(true)).to eq('true')
    end

    it 'converts boolean false to string' do
      expect(stringify_keys(false)).to eq('false')
    end

    it 'returns symbols unchanged' do
      expect(stringify_keys(:symbol)).to eq(:symbol)
    end

    it 'handles symbols as hash values' do
      input = { 'key' => :symbol_value, 'other' => 'string' }
      expected = { 'key' => :symbol_value, 'other' => 'string' }
      expect(stringify_keys(input)).to eq(expected)
    end
  end

  describe 'with Vault-like secret scenarios' do
    it 'processes typical Vault secret structure' do
      input = {
        :database_url => 'postgresql://localhost:5432/mydb',
        :api_key => 'abc123def456',
        :redis_url => 'redis://localhost:6379',
        :environment => 'production'
      }
      expected = {
        'database_url' => 'postgresql://localhost:5432/mydb',
        'api_key' => 'abc123def456',
        'redis_url' => 'redis://localhost:6379',
        'environment' => 'production'
      }
      expect(stringify_keys(input)).to eq(expected)
    end

    it 'converts numeric and boolean values to strings in Vault secrets' do
      input = {
        :database_port => 5432,
        :max_connections => 100,
        :ssl_enabled => true,
        :debug_mode => false,
        :timeout => 30.5
      }
      expected = {
        'database_port' => '5432',
        'max_connections' => '100',
        'ssl_enabled' => 'true',
        'debug_mode' => 'false',
        'timeout' => '30.5'
      }
      expect(stringify_keys(input)).to eq(expected)
    end

    it 'raises error for secret with empty API key' do
      input = {
        :database_url => 'postgresql://localhost:5432/mydb',
        :api_key => '',  # Empty API key - should fail
        :redis_url => 'redis://localhost:6379',
        :debug_mode => false
      }
      expect { stringify_keys(input) }.to raise_error(ArgumentError, "Empty or blank string value found: ''")
    end

    it 'raises error for secret with nil Redis URL' do
      input = {
        :database_url => 'postgresql://localhost:5432/mydb',
        :api_key => 'abc123def456',
        :redis_url => nil,  # Null Redis URL - should fail
        :debug_mode => false
      }
      expect { stringify_keys(input) }.to raise_error(ArgumentError, "Nil value found for key 'redis_url'")
    end

    it 'raises error for complex nested structure with empty values' do
      input = {
        :database => {
          :connections => [
            { :host => 'localhost', :port => 5432, :password => 'secret123' },
            { :host => 'remote', :port => 5432, :password => '' }  # Empty password should fail
          ],
          :credentials => {
            :username => 'user',
            :password => 'secret123'
          }
        }
      }

      expect { stringify_keys(input) }.to raise_error(ArgumentError, "Empty or blank string value found: ''")
    end

    it 'raises error for nested structure with nil values' do
      input = {
        :cache => {
          :enabled => true,
          :redis_config => {
            :url => 'redis://localhost:6379',
            :timeout => nil  # Nil timeout should fail
          }
        }
      }

      expect { stringify_keys(input) }.to raise_error(ArgumentError, "Nil value found for key 'timeout'")
    end

    it 'raises error for completely empty secret hash values' do
      input = {
        :key1 => nil,
        :key2 => '',
        :key3 => '   '
      }
      # Should fail on the first nil value encountered
      expect { stringify_keys(input) }.to raise_error(ArgumentError, "Nil value found for key 'key1'")
    end

    it 'raises error for secret with empty configuration hash' do
      input = {
        :database_url => 'postgresql://localhost:5432/mydb',
        :api_config => {},  # Empty configuration should fail
        :redis_url => 'redis://localhost:6379'
      }
      expect { stringify_keys(input) }.to raise_error(ArgumentError, "Empty hash found")
    end

    it 'raises error for secret with empty list configuration' do
      input = {
        :database_url => 'postgresql://localhost:5432/mydb',
        :allowed_hosts => [],  # Empty list should fail
        :redis_url => 'redis://localhost:6379'
      }
      expect { stringify_keys(input) }.to raise_error(ArgumentError, "Empty array found")
    end
  end
end