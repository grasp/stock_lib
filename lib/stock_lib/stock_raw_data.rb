require 'optparse'
require 'rest_client'
module StockLib

	class StockRawData
		def initialize(code)

     #创建根目录
      root_path=$root_path || "d:\\stock_analysis"
      Dir.mkdir(root_path)  unless File.exists?(root_path)

     #创建分析目录，以代码为名字
      symbol_path=File.expand_path(code,root_path)
      Dir.mkdir(symbol_path) unless File.exists?(symbol_path)

      #raw_data analysis
      @raw_data_path=File.expand_path("raw_data",symbol_path)
      Dir.mkdir(@raw_data_path) unless File.exists?(@raw_data_path)
      
		end

# 这个有问题，不工作了
    def download_yahoo_history_data(code,number_day)
      exe_path=File.expand_path("../yahoofinance.rb",__FILE__)
     puts "exe_path=#{exe_path}"
      command_run="ruby #{exe_path} -z -d #{number_day} #{code}"
      result=`#{command_run}`
      puts result
      raise if result.size.nil?
     # target_folder=File.join(Strategy.send(strategy).root_path,symbol,Strategy.send(strategy).raw_data,Strategy.send(strategy).history_data)
     
      target_folder=@raw_data_path
      puts "target_folder=#{target_folder}"
      raise unless File.exists?(target_folder)

      symbole_file_name=File.expand_path("#{code}.txt",target_folder)
      symbol_file=File.new(symbole_file_name,"w+")

      result.split("\n").reverse.each do |line|
        next if line.match("Retrieving")
        line_result=line.split(",")
        next if line_result[6]=="000" && line_result[0]!="000001.ss" # 扣除那些成交量为0的交易日数据
        symbol_file<<line+"\n"  
      end
      symbol_file.close
      end

      def sina_download_history(code,start_date,end_date)
       
        sina_id=code.split(".").reverse.join  if code.match("sz")
        sina_id=code.gsub("ss","sh").split(".").reverse.join  if code.match("ss")

        startdate=start_date.gsub("-","").to_s
        enddate=end_date.gsub("-","").to_s

        url="http://biz.finance.sina.com.cn/stock/flash_hq/kline_data.php?&rand=random(10000)&symbol=#{sina_id}&end_date=#{enddate}&begin_date=#{startdate}&type=plain"
        response=""     
       # puts url
        response=RestClient.get url
        #puts response
        sina_array=response.to_s.split("\n")
       # puts sina_array
        #1=>开盘
        #2=>最高
        #3=>收盘
        #4->最低
        #5= 成交量

        #开盘，最高，最低，收盘，成交量
        #print "#{sina_array}\n"
        return_array=Array.new
        sina_array.each do |daily_k|
         #print "#{daily_k} \n"
         new_array=[]
         result=daily_k.split(",")
         temp=result[4]
         result[4]=result[3]
         result[3]=temp

         # print "#{result}\n"
         new_array<<code
         new_array+=result     
         new_array[new_array.size-1]=new_array[new_array.size-1].to_i*100
         
         new_array<<result[4] #为了和yahoo保持一致
         #print "new_array=#{new_array}"
         return_array<<new_array
     end

#转化成文本行，并附加到文件中
 raw_data_path=File.join(@raw_data_path,"#{code}.txt")

 raw_data_file=File.new(raw_data_path,"w+")

 return_array.each do |daily_k|
    daili_k_line=daily_k.join(",")+"\n"
    raw_data_file<<daili_k_line
 end

 raw_data_file.close
      end

	end

end


if $0==__FILE__
  include StockLib

  options = {}

  option_parser = OptionParser.new do |opts|
    opts.banner = 'stock_raw_data helper'

    opts.on('-c CODE', '--code CODE', 'stock symbol code') do |value|
      options[:code] = value
    end

    # Option 作为 flag，带一组用逗号分割的arguments，用于将arguments作为数组解析
    opts.on('-d days', '--days days', Integer, 'List of arguments') do |value|
      options[:days] = value
    end

    opts.on('-s source', '--source source', String, 'source download') do |value|
      options[:source] = value
    end

  end.parse!

 stock_raw_data=StockRawData.new(options[:code])
 if options[:source]=="yahoo"
 stock_raw_data.download_yahoo_history_data(options[:code],options[:days])
end

 if options[:source]=="sina"
  end_date=(Time.now).to_s[0..9]
  start_date=(Time.now-options[:days]*86400).to_s[0..9]
   stock_raw_data.sina_download_history(options[:code],start_date,end_date)
  end

  puts options.inspect

end


#example command_run
#D:\IdeaLab\stock_lib\lib\stock_lib>ruby stock_raw_data.rb -c 000002.sz -d 2000 -s sina