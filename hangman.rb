require 'yaml'

class Hangman

    private
    
    def initialize
        if File.exist("saves/*") # TODO: this will need to change order a lot
            self.from_yaml(file)
        end
        @guesses_remaining = 10
        @setter = nil
        @guesser = nil
        2.times {|i| self.create_player}
        @word = @setter.set_word
        @hint = Array.new(@word.length, " _ ")
        self.guess
    end

    def create_player
        puts "What's your name? (Enter 'CPU' for CPU player)"
        name = gets.chomp.capitalize
        
        puts "Will you guess or set the word?"
        role = gets.chomp.downcase
        if role != "guess" && role != "set"
            puts "***Oops, you made a typo***"
            return self.create_player
        end

        if name == "Cpu"
            player = Computer.new
        else
            player = Human.new(name)
        end

       if role == "guess" && @guesser == nil
            @guesser = player
       elsif role == "set" && @setter == nil
            @setter = player
       else
            puts "***You can't have the same role; #{name} choose your role again***"
            self.create_player
       end
    end

    def guess
        puts "Hint: #{@hint.join}"
        
        guess = @guesser.guess

        if guess == "save"
            self.to_yaml
        elsif @guesser.previous_guesses.any?(guess)
            puts "You've already guessed that!"
            return self.guess
        elsif guess.length > 1
            self.word_guess(guess)
        else
            self.letter_guess(guess)
        end


        # TODO: if the player enters "save" as their guess, save gamestate info to a file
            # guesses remaining, current revealed letters, previous guesses, player name

        @guesses_remaining -= 1
        puts "#{@guesses_remaining} guesses remaining"
        if @guesses_remaining <= 0 
            puts "Bad luck #{@guesser.name}, the word was #{@word.join}"
            self.end_game 
        elsif @word == @hint
            "Congratulations #{@setter.name}, you win!"
            return self.end_game
        end
        @setter.points += 1
        self.guess
    end

    def to_yaml # TODO: find out if this saves the complete player with all its contents. Also I don't think this makes a file yet
        YAML.dump ({
            :guesses_remaining => @guesses_remaining
            :setter => @setter
            :guesser => @guesser
            :word => @word
            :hint => @hint
        })
    end

    def self.from_yaml(file)
        save_file = YAML.load(file)
        @guesses_remaining = save_file[:guesses_remaining]
        @setter = save_file[:setter]
        @guesser = save_file[:guesser]
        @word = save_file[:word]
        @hint = save_file[:hint]
    end

    def word_guess(guess)
        if guess == @word.join
            puts "Congratulations #{@setter.name}, you win!"
            return self.end_game
        else
            puts "Sorry #{@guesser.name}, your guess was incorrect"
            return self.guess
        end
        @guesser.previous_guesses.push(guess)
    end

    def letter_guess(guess)
        if @word.any?(guess)
            puts "Congrats, your guess matched at least one letter!"
            @word.each_index do |index|
                if guess == @word[index]
                    @hint[index] = guess
                end
            end
        else
            puts "Sorry #{@guesser.name}, no matches"
        end
        @guesser.previous_guesses.push(guess)
    end

    def end_game
        puts "The final score is #{@guesser.name}: #{@guesser.points} - #{@setter.name}: #{@setter.points}"
        puts "Would you like to play again? (y/n)"
        response = gets.chomp.downcase
        if response == "y"
            self.reset_game
        else
            exit(0)
        end
    end
    
    def reset_game
        @setter = temp
        @setter = @guesser
        @guesser = temp
        @guesses_remaining = 10
    end
end

class Human
    
    attr_accessor :name, :points, :previous_guesses

    def set_word
        puts "#{@name}, what's your word?"
        word = gets.chomp.downcase.split(//)
        system("clear") || system("cls")
        word
    end

    def guess
        puts "#{@name}, guess a letter or word (or enter 'save' to save the game"
        gets.chomp.downcase
    end

    private

    def initialize(name)
        @name = name
        @points = 0
        @previous_guesses = Array.new
    end
end

class Computer
    
    attr_accessor :name, :points, :previous_guesses

    def set_word
        valid_words = @DICTIONARY.select {|word| word.length > 4 && word.length < 13}
        valid_words[Random.rand(valid_words.length)].chomp.downcase.split(//)
    end

    def guess
         # TODO: let the CPU guess a word you set

    # start by guessing from the most common English letters e-t-a-o-i-n 

    # if you want to be a giant nerd have it then check what words from its dictionary are possible, then the most common letter from those words in the empty space
    end

    private
    
    def initialize
        # load the dictionary
        if File.exist?("google-10000-english-no-swears.txt")
            @DICTIONARY = File.open("google-10000-english-no-swears.txt").readlines
        else
            puts "Dictionary is missing"
        end
        @name = "CPU"
        @points = 0
        @previous_guesses = Array.new
    end
end

game = Hangman.new