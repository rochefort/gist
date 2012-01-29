require 'rubygems'
require 'thor'
require 'net/http'
require 'json'
require 'gist/my_util'

module Gist
  class RedirectError < StandardError; end
  API_URL = 'https://api.github.com'  

  class Main < Thor
    include MyUtil

    desc 'list', 'List your gists'
    def list
      setup
      write_list_header
      @data.each_with_index do |list, i|
        puts "%4s. %10s  %s" % [i+1, list['id'], list['description']]
      end
      write_footer
    end

    desc 'show [ID/NUMBER]', 'Show your raw gist by id or the listing number'
    def show(arg)
      raise ArgumentError "#{arg} is not numerical" unless numeric?(arg)
      setup
      content = []
      # IDで検索
      @data.each_with_index do |list, i|
        content = get_content(i) and break if list['id'] == arg
      end

      # 番号で検索
      if content.empty? and number_of?(arg.to_i)
        content = get_content(arg.to_i-1)
      end
      puts content
    end

    private
    def get_content(n)
      @data[n]['files'].values.inject([]) do |content, file|
        content << ''
        content << "file: #{file['filename']}"
        content << '-'*100
        content << get_body(file['raw_url'])
        content << ''
      end
    end

    def number_of?(n)
      n > 0 and @data.size >= n
    end

    def setup
      @user = ENV['GIST_USER'] || gitconfig_user
      raise ArgumentError, "Set ENV['GIST_USER'] or 'git config user.name <your_name>'" if @user.empty?
      @data = JSON.parse(get_list)
      # debug
      #cache_file = "#{ENV['HOME']}/.gist/data.txt"
      #@data = JSON.parse(File.open(cache_file).read) if File.exist?(cache_file)
    end

    def write_list_header
      puts
      puts '  No.    ID       Description'
      puts '-'*120
    end

    def write_footer
      puts
    end

    # return blank if there is nothing
    def gitconfig_user
      `git config --get user.name`.chomp
    end

    def get_list
      get_body(API_URL + "/users/#{@user}/gists")
    end
  end
end
