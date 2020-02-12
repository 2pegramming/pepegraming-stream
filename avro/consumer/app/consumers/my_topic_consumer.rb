class MyTopicConsumer < ApplicationConsumer
  def consume
    puts '*' * 80

    params_batch.each do |message|
      puts message
    end
  end
end
