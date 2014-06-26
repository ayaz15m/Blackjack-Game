require 'colorize'

class Card

  attr_accessor :card, :suit

  def initialize(card, suit)
    @card = card
    @suit = suit
  end
end

class Deck

  def deck_of_cards

    @deck = []

    values = ["A ","K ","Q ","J ","10", "9 ","8 ","7 ","6 ","5 ","4 ","3 ","2 "]
    suits = ["♧", "♢", "♡", "♤"]

    suits.each do |suit|
      values.each do |value|
        @deck << Card.new(value, suit)
      end
    end

    return shuffled_deck = @deck.shuffle
  end

  def deal_card(deck)
    card = deck.sample(1).first
  end
end

class Hand

  def hands
    deck = Deck.new.deck_of_cards

    p_card1 = Deck.new.deal_card(deck)
    deck = remove_card_from_deck(deck, p_card1)

    d_card1 = Deck.new.deal_card(deck)
    deck = remove_card_from_deck(deck, d_card1)

    p_card2 = Deck.new.deal_card(deck)
    deck = remove_card_from_deck(deck, p_card2)

    d_card2 = Deck.new.deal_card(deck)
    deck = remove_card_from_deck(deck, d_card2)

    args = {}
    args[:p_card1] = p_card1
    args[:p_card2] = p_card2
    args[:d_card1] = d_card1
    args[:d_card2] = d_card2
    args[:deck] = deck

    return args
  end

  def remove_card_from_deck(deck, card)
    new_deck = deck.reject do |deck|
      deck == card
    end
    return new_deck
  end
end

class Gameplay
  def get_color(card)
    if card == "♧"
      color = :black
    elsif card == "♢"
      color = :red
    elsif card == "♡"
      color = :red
    elsif card == "♤"
      color = :black
    end
  end

  def print_card(card)
    card.each do |cards|
      print " #{cards.card}#{cards.suit}          ".colorize(color: get_color(cards.suit), background: :white)
      print " "
      if card.count == 1
        yield
      end
    end
    5.times do
      puts "\n"
      card.count.times do
        print"              ".colorize(background: :white)
        print " "
        if card.count == 1
          yield
        end
      end
    end
    puts "\n"
    card.each do |cards|
      print "          #{cards.card}#{cards.suit} ".colorize(color: get_color(cards.suit), background: :white)
      print " "
      if card.count == 1
        yield
      end
    end
    puts "\n"
  end

  def play(money)
    puts "Play Blackjack!"
    puts "\nInstructions: Try to beat the dealer without going over 21."
    puts "Enter h to hit, s to stand, or q to quit the game."
    puts "\n"
    puts "NOTE: In a hand the first Ace counts as 11 and each Ace after counts as 1"
    puts "\n"

    cards = Hand.new.hands

    @deck = cards[:deck]

    player_cards = []
    player_cards << cards[:p_card1]
    player_cards << cards[:p_card2]
    player_total = get_total(player_cards)

    is_correctly_set = false

    until is_correctly_set
      print "You have $#{money}. How much would you like to bet? "
      bet = gets.chomp.strip.downcase
      puts "\n"
      if bet == "q"
        exit
      end

      bet = bet.to_i

      if bet <= money && bet > 0
        is_correctly_set = true
      else
        puts "Please enter a valid bet greater than 0 and less than #{money}."
      end
    end

    puts "\nPlayer:"

    print_card(player_cards)

    puts "Total = #{player_total}.\n"

    dealer_cards = []
    dealer_cards << cards[:d_card1]

    puts "\n"
    puts "Dealer:"

    print_card(dealer_cards) do
      print"              ".colorize(background: :light_black)
      print " "
    end


    dealer_cards << cards[:d_card2]
    dealer_total = get_total(dealer_cards)

    win = ""

    if player_total == 21 && dealer_total != 21
      puts "CONGRATULATIONS! You got a blackjack!!".colorize(color: :cyan).blink
      win = "BJ"

      factor = win_factor(win)
      winnings = factor*bet
      return winnings

     elsif player_total == 21 && dealer_total == 21
      puts "Both player and dealer have blackjack. PUSH".colorize(color: :yellow).blink
      win = "Push"

      factor = win_factor(win)
      winnings = factor*bet
      return winnings
    end

    player_total = player(player_cards)

    if player_total < 22

      dealer_total = get_total(dealer_cards)

      puts "Dealer:"

      print_card(dealer_cards)

      puts "Total = #{dealer_total}.\n"

      puts "\n"

      if dealer_total == 21
        puts "Dealer has blackjack. You lose :(".colorize(color: :red).blink
        win = "No"

        factor = win_factor(win)
        winnings = factor*bet
        return winnings
      end

      dealer_total = dealer(dealer_cards)

      puts "Player Total = #{player_total}    Dealer Total = #{dealer_total}"
      puts "\n"

      if dealer_total < 22
        if player_total < dealer_total
          puts "Dealer wins :(".colorize(color: :red).blink
          win = "No"

        elsif player_total > dealer_total
          puts "YOU WIN!!!!".colorize(color: :cyan).blink
          win = "Yes"

        elsif player_total == dealer_total
          puts "Push :P".colorize(color: :yellow).blink
          win = "Push"
        end
      else
        puts "Dealer bust. You WIN!!!".colorize(color: :cyan).blink
        win = "Yes"
      end
    else
      puts "Player Total = #{player_total}"
      puts "\n"
      puts "BUST! Better luck next time!".colorize(color: :red).blink
      win = "No"
    end

    factor = win_factor(win)
    winnings = factor*bet
    return winnings
  end

  def win_factor(win)
    if win == "BJ"
      factor = 1.5
    elsif win == "Push"
      factor =  0
    elsif win == "Yes"
      factor = 1
    elsif win == "No"
      factor = -1
    end
    return factor
  end

  def player(cards)
    is_correctly_set = false
    until is_correctly_set
      puts "\n"
      print "Do you wish to hit or stand(h/s)? "
      answer = gets.chomp.strip.downcase
      puts "\n"

      if answer == "h"
        puts "Player:"

        cards = hit(cards)

        total = get_total(cards)
        puts "Player new total = #{total}."
        puts "\n"

        if total > 21
          is_correctly_set = true
        end
      elsif answer == "s"

        total = get_total(cards)
        is_correctly_set = true
      elsif answer == "q"
        exit
      else
        puts "Please enter valid response."
      end
    end
    return total
  end

  def dealer(cards)

    total = get_total(cards)

    until total>16
      puts "Dealer:"
      cards = hit(cards)

      total = get_total(cards)

      puts "Dealer new total = #{total}"
      puts "\n"
    end

    return total
  end

  def get_total(cards)
    total = 0

    aces = cards.select do |card|
      card.card == "A "
    end

    if aces.count > 1
      cards.each do |card|
        total += get_card_value(card.card)
      end
      total = total - (aces.count-1)*10
    else
      cards.each do |card|
        total += get_card_value(card.card)
      end
    end
    return total
  end

  def hit(cards)
    card = Deck.new.deal_card(@deck)
    @deck = Hand.new.remove_card_from_deck(@deck, card)

    cards << card
    print_card(cards)

    return cards
  end

  def get_card_value(card)
    if card == "A "
      card = 11
    elsif card == "K "
      card = 10
    elsif card == "Q "
      card = 10
    elsif card == "J "
      card = 10
    elsif card == "10"
      card = 10
    elsif card == "9 "
      card = 9
    elsif card == "8 "
      card = 8
    elsif card == "7 "
      card = 7
    elsif card == "6 "
      card = 6
    elsif card == "5 "
      card = 5
    elsif card == "4 "
      card = 4
    elsif card == "3 "
      card = 3
    elsif card == "2 "
      card = 2
    end
    return card
  end
end

class Blackjack
  def main
    balance = 1000
    winnings = Gameplay.new.play(balance)
    balance = money(balance,winnings)

    puts "\n"
    puts "You now have $#{balance}"

    if balance <= 0
      puts "Your balance zero, here is a gift of $1000!"
      balance = 1000
    end

    is_correctly_set = false

    until is_correctly_set
      puts "\n"
      print "Do you want to play again(y/n?) "
      answer = gets.chomp.strip.downcase
      puts "\n"

      if answer == "y"
        system "clear" or system "cls"

        winnings = Gameplay.new.play(balance)
        balance = money(balance,winnings)

        puts "\n"
        puts "You now have $#{balance}"

        if balance <= 0
          puts "Your balance zero, here is a gift of $1000!"
          balance = 1000
        end

      elsif answer == "n"
        is_correctly_set = true
      elsif answer == "q"
          exit
      else
        puts "Please enter valid response."
      end
    end
  end

  def money(balance, winnings)
    balance += winnings
    return balance
  end
end

system "clear" or system "cls"

Blackjack.new.main
