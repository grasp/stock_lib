require File.expand_path("../raw_data_process.rb",__FILE__)

module StockLib
	class SignalProcess < RawDataProcess
		def initialize(code)
			super(code)
		end

	def generate_signal
		@date_array.each_index do |index|
			print  @date_array[index]+"#############################"
			generate_on_index(index)
		end
	end

	def generate_on_index(i)

		date=@date_array[i]
		#puts date
     	date_folder=File.expand_path(date,@processed_date)
        signal_file=File.expand_path("signal_#{date}.txt",date_folder)
        # puts "generate on #{i}"
        if not File.exists?(signal_file)
	        today_input=@processed_raw_array[i]
	     	history_array=@processed_raw_array[0..(i-1)].reverse
           true_hash= generate_singal(history_array,today_input)
           print "#{true_hash.size}"
           puts
	    end
	end


	def generate_singal(histroy_array,today_input)
        
		macd_today=today_input[0]
		macd_2day=histroy_array[0][0]
		histroy_array[1] =histroy_array[0] if histroy_array[1].nil?
		macd_3day=histroy_array[1][0] 

        signal_hash=Hash.new
        #这里没有处理2日穿5日的情况
		 @day_array.each_index do |i|
		 if (macd_today[i].to_f > macd_2day[i].to_f) && (macd_2day[i].to_f < macd_3day[i].to_f)
		 	signal_hash["price_average#{i}"]=true
		 else
		 	signal_hash["price_average#{i}"]=false
		 end
		end
[[2,5],[2,7],[3,7],[5,8],[5,10],[7,14],[8,15]].each do |array|

		(macd_today[array[0]-1].to_f > macd_today[array[1]-1].to_f) && (macd_2day[array[0]-1].to_f < macd_2day[array[1]-1].to_f) \
		? signal_hash["price_average#{array[0]}_#{array[1]}"]=true : signal_hash["price_average#{array[0]}_#{array[1]}"]=false

end


       #最低价格信号发出
		 low_price_today=today_input[1]
		 low_price_2day=histroy_array[0][1]
		 #low_price_3day=histroy_array[1][1]
  #print  low_price_today
  #puts 
  #print  low_price_2day
         @day_array.each_index do |i|
         	if low_price_today[i].to_f<low_price_2day[i].to_f 
         		
         	#	signal_hash["lowest_#{i}"]=true

         	else
         	#	signal_hash["lowest_#{i}"]=false
         	end
         end

        #最高价格信号发出
        high_price_today=today_input[2]
        high_price_2day=histroy_array[0][2]

        @day_array.each_index do |i|
         	if high_price_today[i].to_f>high_price_2day[i].to_f 
         		#signal_hash["highest_#{i}"]=true
         	else
         	#	signal_hash["highest_#{i}"]=false
         	end
         end

        #量的信号
        volume_today=today_input[3]
        volume_2day=histroy_array[0][3]
       #  print volume_today
       #  puts
       #  print volume_2day

        @day_array.each_index do |i|
         	if volume_today[i].to_f>volume_2day[i].to_f 
         		#signal_hash["volume_#{i}"]=true
         	else
         		#signal_hash["volume_#{i}"]=false
         	end
         end

true_hash=Hash.new
  signal_hash.each do |key,value|
  puts "#{key}=#{value}" if value==true
  true_hash[key]=value if value==true
  end
 # signal_hash
true_hash
end #end of definiton
	end #end of class
end #end of module


if $0==__FILE__
	include StockLib
	signal_process=SignalProcess.new("000002.sz")
	signal_process.generate_all_date
	signal_process.generate_signal
end