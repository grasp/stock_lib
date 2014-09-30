module StockLib

  class RawDataProcess
  	def initialize(code)
	  root_path=$root_path || "d:\\stock_analysis"
	  @raw_data_path=File.join(root_path,code,"raw_data")
	  @processed_date=File.join(root_path,code,"processed_date")
	  Dir.mkdir(@processed_date) unless File.exists?(@processed_date)

	  raw_data_file=File.expand_path("#{code}.txt",@raw_data_path)
	  daily_k_array=File.read(raw_data_file).split("\n")

	 #  @day_array=[1,2,3,4,5,10,20,30,60,100,120,200]
	  @day_array=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,20,30,60,100,120,200]

  #生成一个日期为key,日线数据为value的Hash
      @price_volume_hash=Hash.new
	  daily_k_array.each do |line|	   
		next if line.nil?   
		daily_data = line.split(",")
		#print daily_data.to_s+"\n"
		next if daily_data.size<3
		@price_volume_hash[daily_data[1]]=[daily_data[2],daily_data[3],daily_data[4],daily_data[5],daily_data[6],daily_data[7]]
      end
   #生成两个数组，一个是日期数组，一个是日线数据，索引是一一对应的
      @date_array=@price_volume_hash.keys #最新的在最后面
      @price_array=@price_volume_hash.values #最新的在最后面

     # print  @date_array

  	end

  	def generate_all_date
  		@processed_raw_array=[]

  		@date_array.each_index do |index|
  			@processed_raw_array<<get_input_on_index(index)
  		end
        puts @processed_raw_array.size
  		@processed_raw_array
  	end

     def get_input_on_index(i)
     	date=@date_array[i]

     	date_folder=File.expand_path(date,@processed_date)
     	 Dir.mkdir(date_folder) unless File.exists?(date_folder)  	

  		 macd_file=File.expand_path("processed_raw_data_#{date}.txt",date_folder)
         if not File.exists?(macd_file)
	         today_input=@price_array[i]
	     	 history_array=@price_array[0..(i-1)]

	     	 macd_array=generate_macd_on_date(date,history_array, today_input)
	         low_high_array=generate_high_low(history_array, today_input)
	         volume_array=generate_volume(history_array, today_input)
	     	 macdfile=File.new(macd_file,"w+")
	     	 macdfile<< macd_array.to_s+";"+low_high_array[0].to_s+";"+low_high_array[1].to_s+";"+volume_array.to_s
	     	 macdfile.close
	     	 return [macd_array,low_high_array[0],low_high_array[1],volume_array]
     	else
     		array=File.read(macd_file).split(";")
            return [eval(array[0]),eval(array[1]),eval(array[2]),eval(array[3])]
     	end
       
     end

  	def generate_macd_on_date(date,history_array, today_input)
        macd_array=[]
  		#最新的在最前面了
  		price_array=(history_array+[today_input]).reverse  

		#计算每一日的各个均值
		@day_array.each do |macd_day|
		sum=0
		#算术求和
		real_day_count=0

		(macd_day-1).downto(0).each do |j|
			#边界处理
			j>price_array.size-1 ? index=price_array.size-1 : index=j
            #print index

			high=price_array[index][1].to_f
			low=price_array[index][2].to_f
			close=price_array[index][3].to_f
            #print close.to_s+" "
			sum+=close  #以收盘价作为均线的数据
			real_day_count+=1

			end  #end of macd_day sum  

			average=((sum.to_f)/real_day_count).round(2)

			raise if average==0.0

			macd_array<<average 
		end #end of one of macd day
		macd_array

  	end  #end of generate macd

  	def generate_high_low(history_array, today_input)
	
		low_price_array=[]
        high_price_array=[]
        price_array=(history_array+[today_input]).reverse

		#计算每一日的各个均值
		@day_array.each do |number_day|
		lowest_price=10000000
		highest_price=-1

		(number_day-1).downto(0).each do |j|
			#边界处理
			j>price_array.size-1 ? index=price_array.size-1 : index=j
			#print "price_array[index]=#{price_array[index]},#{index}" if  price_array[index].nil?

			#比较
			lowest_price=price_array[index][3] if price_array[index][3].to_f < lowest_price.to_f
			highest_price= price_array[index][3]  if highest_price.to_f<price_array[index][3].to_f

		end  #end of macd_day sum 

        raise if lowest_price.nil?
        low_price_array<<lowest_price
        high_price_array<<highest_price
  	end
  	[low_price_array,high_price_array]
  end

  def generate_volume(history_array, today_input)
 
 
    price_array=(history_array+[today_input]).reverse

   volume_array=[]

   #计算每一日的各个均值
   @day_array.each do |number_day|
    sum=0
    count=0
    (number_day-1).downto(0).each do |j|#修复一个边界问题
        #边界处理
        j>price_array.size-1 ? index=price_array.size-1 : index=j
        sum+=price_array[index][4].to_f
        count+=1 
    end  #end of macd_day sum  
    average_volume=(sum.to_f/count.to_f).round(2)
    volume_array << average_volume
 
    end #end of one of macd day 
   volume_array
  end

  end
end

if $0==__FILE__
	include StockLib
	raw_data_process=RawDataProcess.new("000002.sz")
    #print raw_data_process.get_input_on_index(121)
    raw_data_process.generate_all_date
end