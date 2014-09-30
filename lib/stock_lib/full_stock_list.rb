module StockLib

class FullStockList
attr_accessor :raw_stock_hash,:sh_stock_list,:sz_stock_list

#初始化，把文本转化成hash
  def initialize#(text_full_path)

    stock_list_file=File.expand_path("../stock_table_2013_10_01.txt",__FILE__)

    @raw_stock_hash=Hash.new
    @sh_stock_list=Hash.new
    @sz_stock_list=Hash.new

    File.open(stock_list_file,"r").each do |line|
      newline=line.force_encoding("utf-8")
      code=newline.match(/^\d\d\d\d\d\d/).to_s.force_encoding("utf-8")
      name=newline.match(/\D+/).to_s.force_encoding("utf-8")
      @raw_stock_hash[code]=name unless code.nil?
    end #end file each open

    #计算上海和深圳的股票列表
    @raw_stock_hash.each do |code,name|
      @sh_stock_list[code+".ss"]=name if  code.match(/^60\d\d\d\d/)
      @sz_stock_list[code+".sz"]=name if  code.match(/^000\d\d\d/) || code.match(/^002\d\d\d/) || code.match(/^300\d\d\d/)
    end

  end #end initialize



end  #end class
end #end stocklib module

if $0==__FILE__
require 'optparse'
include StockLib

full_stock_list=FullStockList.new

options = {}

option_parser = OptionParser.new do |opts|
  opts.banner = 'full_stock_list help informaiton'

  # 下面第一项是 Short option（没有可以直接在引号间留空），第二项是 Long option，第三项是对 Option 的描述
  opts.on_tail('-c', '--count', 'options to print statistic information') do |a|
    # 这个部分就是使用这个Option后执行的代码
   # options[:count] = true
    puts  "全部股票 #{full_stock_list.raw_stock_hash.size}只"
    puts  "上海股票 #{full_stock_list.sh_stock_list.size}只"
    puts  "深圳股票 #{full_stock_list.sz_stock_list.size}只"

  # puts "count=#{a}"
  end

end.parse!

puts options.inspect

end
