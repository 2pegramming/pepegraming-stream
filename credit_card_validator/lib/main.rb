class CardChecker
  def call(card)
    fail if card != card.to_s
    fail if card.size != 16

    card_nunber = card.split('').map(&:to_i)
    accum = []

    card_nunber.each_with_index do |number, index|
      if index.even?
        new_number = number * 2 

        accum << ((new_number > 9) ? (new_number - 9) : new_number)
      else
        accum << number
      end
    end

    (accum.sum % 10) == 0
  end
end

class CardGenerator
  CARD_TYPES = {
    visa: [[4]],
    mastercard: [[5, 1], [5, 2], [5, 3], [5, 4], [5, 5]]
  }

  def call(type:)
    begin
      card_numbers = CARD_TYPES.fetch(type).sample
      card_numbers += generate_number(16 - card_numbers.size)

      generated_card = card_numbers.join
    end until CardChecker.new.call(generated_card)

    generated_card
  end

private

  def generate_number(count)
    acc = []
    (count).times { acc << rand(0..9) }
    acc
  end
end


