# -*- coding: utf-8 -*-
require 'spec_helper'

# comma do
#   name 'Title'
#   description
#
#   isbn :number_10 => 'ISBN-10', :number_13 => 'ISBN-13'
# end

RSpec.describe Comma::HeaderExtractor do

  before do
    @isbn = Isbn.new('123123123', '321321321')
    @book = Book.new('Smalltalk-80', 'Language and Implementation', @isbn)

    @headers = @book.to_comma_headers
  end

  describe 'when no parameters are provided' do

    it 'should use the method name as the header name, humanized' do
      expect(@headers).to include('Description')
    end
  end

  describe 'when given a string description as a parameter' do

    it 'should use the string value, unmodified' do
      expect(@headers).to include('Title')
    end
  end

  describe 'when an hash is passed as a parameter' do

    describe 'with a string value' do

      it 'should use the string value, unmodified' do
        expect(@headers).to include('ISBN-10')
      end
    end

    describe 'with a non-string value' do

      it 'should use the non string value converted to a string, humanized' do
        expect(@headers).to include('Issuer')
      end
    end

  end

end

RSpec.describe Comma::HeaderExtractor, 'with static column method' do
  before do
    @headers = Class.new(Struct.new(:id, :name)) do
      comma do
        __static_column__
        __static_column__ 'STATIC'
        __static_column__ 'STATIC' do '' end
      end
    end.new(1, 'John Doe').to_comma_headers
  end

  it 'should extract headers' do
    expect(@headers).to eq(['', 'STATIC', 'STATIC'])
  end
end
