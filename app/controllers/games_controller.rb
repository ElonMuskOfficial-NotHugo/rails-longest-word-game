require 'open-uri'

class GamesController < ApplicationController
  def new
    alphabet = ('A'..'Z').to_a
    @random_letter_array = []
    10.times do
      random_letter = alphabet.sample
      @random_letter_array << random_letter
    end
  end

  def answer_valid?(submitted_answer)
    @submitted_letter_array = submitted_answer.chars
    @random_letter_array = params[:letters].split(' ').join.chars

    @submitted_letter_counts = count_letters(@submitted_letter_array)
    @random_letter_counts = count_letters(@random_letter_array)

    result = @submitted_letter_counts.all? do |letter, count|
      count <= @random_letter_counts[letter].to_i
    end
    @result = result
  end

  def count_letters(letter_array)
    return {} if letter_array.nil?

    letter_counts = {}
    letter_array.each do |letter|
      if letter_counts.key?(letter)
        letter_counts[letter] += 1
      else
        letter_counts[letter] = 1
      end
    end
    letter_counts
  end

  def real_word?(submitted_answer)
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{submitted_answer}")
    json = JSON.parse(response.read)
    json['found']
  end

  def score
    @submitted_answer = params[:answer].upcase
    if @submitted_answer == ''
      @final_result = 'Please enter some actual characters'
    else
      if answer_valid?(@submitted_answer)
        if real_word?(@submitted_answer)
          @final_result = "Congratulations! #{@submitted_answer} is a valid English word."
        else
          @final_result = 'This is not a real word'
        end
      else
        @final_result = "Your answer is  #{@submitted_answer}. Incorrect characters used"
      end
    end
  end
end
