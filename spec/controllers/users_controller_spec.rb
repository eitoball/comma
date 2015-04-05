require 'spec_helper'

if defined?(Rails)

  RSpec.describe UsersController, type: :controller do

    describe "rails setup" do

      it 'should capture the CSV renderer provided by Rails' do
        mock_users = [object_double(User.new), object_double(User.new)]
        allow(User).to receive(:all).and_return(mock_users)

        expect(mock_users).to receive(:to_comma).once

        get :index, :format => :csv
      end

    end

    describe "controller" do
      before(:all) do
        @user_1 = User.create!(:first_name => 'Fred', :last_name => 'Flintstone')
        @user_2 = User.create!(:first_name => 'Wilma', :last_name => 'Flintstone')
      end

      it 'should not affect html requested' do
        get :index

        expect(response.status).to eq(200)
        expect(response.content_type).to eq('text/html')
        expect(response.body).to eq('Users!')
      end

      it "should return a csv when requested" do
        get :index, :format => :csv

        expect(response.status).to eq(200)
        expect(response.content_type).to eq('text/csv')
        expect(response.header["Content-Disposition"]).to include('filename="data.csv"')

        expected_content =<<-CSV.gsub(/^\s+/,'')
        First name,Last name,Name
        Fred,Flintstone,Fred Flintstone
        Wilma,Flintstone,Wilma Flintstone
        CSV

        expect(response.body).to eq(expected_content)
      end

      describe 'with comma options' do

        it 'should allow the style to be chosen from the renderer' do
          #Must be passed in same format (string/symbol) eg:
          # format.csv  { render User.all, :style => :shortened }

          get :with_custom_style, :format => :csv

          expected_content =<<-CSV.gsub(/^\s+/,'')
          First name,Last name
          Fred,Flintstone
          Wilma,Flintstone
          CSV

        expect(response.body).to eq(expected_content)
        end

      end

      describe 'with custom options' do

        it 'should allow a filename to be set' do
          get :with_custom_options, :format => :csv, :custom_options => { :filename => 'my_custom_name' }

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('text/csv')
          expect(response.header["Content-Disposition"]).to include('filename="my_custom_name.csv"')
        end

        it "should allow a custom filename with spaces" do
          require 'shellwords'
          get :with_custom_options, :format => :csv, :custom_options => { :filename => 'filename with a lot of spaces' }

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('text/csv')
          expect(response.header["Content-Disposition"]).to include('filename="filename with a lot of spaces.csv"')

          filename_string = response.header["Content-Disposition"].split('=').last
          # shellsplit honors quoted strings
          expect(filename_string.shellsplit.length).to eq(1)
        end

        it 'should allow a file extension to be set' do
          get :with_custom_options, :format => :csv, :custom_options => { :extension => :txt }

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('text/csv')
          expect(response.header["Content-Disposition"]).to include('filename="data.txt"')
        end

        it 'should allow mime type to be set' do
          get :with_custom_options, :format => :csv, :custom_options => { :mime_type => Mime::TEXT }
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('text/plain')
        end

        describe 'headers' do

          it 'should allow toggling on' do
            get :with_custom_options, :format => :csv, :custom_options => { :write_headers => 'true' }

            expect(response.status).to eq(200)
            expect(response.content_type).to eq('text/csv')

            expected_content =<<-CSV.gsub(/^\s+/,'')
            First name,Last name,Name
            Fred,Flintstone,Fred Flintstone
            Wilma,Flintstone,Wilma Flintstone
            CSV

            expect(response.body).to eq(expected_content)
          end

          it 'should allow toggling off' do
            get :with_custom_options, :format => :csv, :custom_options => {:write_headers => false}

            expect(response.status).to eq(200)
            expect(response.content_type).to eq('text/csv')

            expected_content =<<-CSV.gsub(/^\s+/,'')
            Fred,Flintstone,Fred Flintstone
            Wilma,Flintstone,Wilma Flintstone
            CSV

            expect(response.body).to eq(expected_content)
          end

        end

        it 'should allow forcing of quotes' do
          get :with_custom_options, :format => :csv, :custom_options => { :force_quotes => true }

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('text/csv')

          expected_content =<<-CSV.gsub(/^\s+/,'')
          "First name","Last name","Name"
          "Fred","Flintstone","Fred Flintstone"
          "Wilma","Flintstone","Wilma Flintstone"
          CSV

          expect(response.body).to eq(expected_content)
        end

        it 'should allow combinations of options' do
          get :with_custom_options, :format => :csv, :custom_options => { :write_headers => false, :force_quotes => true, :col_sep => '||', :row_sep => "ENDOFLINE\n" }

          expect(response.status).to eq(200)
          expect(response.content_type).to eq('text/csv')

          expected_content =<<-CSV.gsub(/^\s+/,'')
          "Fred"||"Flintstone"||"Fred Flintstone"ENDOFLINE
          "Wilma"||"Flintstone"||"Wilma Flintstone"ENDOFLINE
          CSV

          expect(response.body).to eq(expected_content)
        end

      end

    end

  end
end
