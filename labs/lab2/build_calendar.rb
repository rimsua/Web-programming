require 'date'

if ARGV.size !=4
  puts "Ошибка: количество аргументов должно быть 4\nФормат: ruby build_calendar.rb teams.txt <дата начала> <дата конца> calendar.txt"
  exit
end

#валидация данных
teams_f,start_d,end_d, output_f = ARGV
begin
  unless File.exist?(teams_f)
    raise "Ошибка: файл #{teams_f} с командами не найден"
  end

  teams=File.readlines(teams_f).map do |line|
    line.sub(/^\d+\.\s*/,'').strip
  end
  start_date = Date.strptime(start_d,'%d.%m.%Y')
  end_date = Date.strptime(end_d,'%d.%m.%Y')
  if start_date>end_date 
    raise "Ошибка: дата в неправильном порядке"
  end 
rescue ArgumentError
  puts "Ошибка: формат даты должен быть dd.mm.yyyy"; exit
rescue => e
  puts "Ошибка валидации: #{e.message}"; exit
end

games = teams.combination(2).to_a.shuffle
slots_for_games=[]
(start_date..end_date).each do |day|
  if [5,6,0].include?(day.wday)
    [12,15,18].each do |hour|
      2.times {slots_for_games << DateTime.new(day.year,day.month, day.day, hour, 0) }
    end
  end
end

if slots_for_games.size<games.size
  raise "Ошибка: Мест не хватает"
end

#равномерное распределение игр
calendar_games = []
step = slots_for_games.size.to_f/games.size
i=0
games.each do |pair|
  idx_slot = (step*i).to_i
  calendar_games << {time: slots_for_games[idx_slot],teams: pair}
  i+=1
end

calendar_games.sort_by!{|game| game[:time]}

#запись в файл
begin
  File.open(output_f,'w') do |f|
    f.puts "Спортивный календарь игр".bold
    f.puts "Даты проведения: #{start_d} - #{end_d}\nКоличество команд: #{teams.size}\nКоличество игр: #{games.size}"
    f.puts "-"*20
    num=1
    calendar_games.each do |match|
      f.puts "#{num}. #{match[:time].strftime("%d.%m.%Y (%a)")} в #{match[:time].strftime("%H:%M")}"
      f.puts "#{match[:teams][0]}\nVS\n#{match[:teams][1]}"
      num+=1
    end
  end
  puts "Календарь успешно создан в файле: #{output_f}"
  rescue => e
  puts "Ошибка: запись в файл не удалась: #{e.message}"
end

