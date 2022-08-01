require 'yaml'

class Hangman

    attr_accessor :guesses_remaining, :hint

    private
    
    def initialize
        @save = "save.yaml"
        if File.exists?(@save)
            self.from_yaml
        else
            @guesses_remaining = 10
            @setter = nil
            @guesser = nil
            2.times {|i| self.create_player}
            @word = @setter.set_word
            @hint = Array.new(@word.length, " _ ")
        end
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
            player = Computer.new(self)
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
            puts "Game saved successfully!"
            exit(0)
        elsif @guesser.previous_guesses.any?(guess)
            puts "You've already guessed that!"
            return self.guess
        elsif guess.length > 1
            self.word_guess(guess)
        else
            self.letter_guess(guess)
        end

        @guesses_remaining -= 1
        if @word == @hint
            "Congratulations #{@guesser.name}, you win!"
            @guesser.points += @guesses_remaining
            return self.end_game
        elsif @guesses_remaining <= 0 
            puts "Bad luck #{@guesser.name}, the word was #{@word.join}"
            return self.end_game 
        end
        puts "#{@guesses_remaining} guesses remaining"
        @setter.points += 1
        self.guess
    end

    def to_yaml
        save_state = YAML.dump ({
            :guesses_remaining => @guesses_remaining,
            :setter => @setter,
            :guesser => @guesser,
            :word => @word,
            :hint => @hint,
        })
        save_file = File.open(@save, "w")
        save_file.puts "#{save_state}"
    end

    def from_yaml
        save_file = File.open(@save)
        save_state = YAML.unsafe_load(save_file)
        File.delete(@save)
        @guesses_remaining = save_state[:guesses_remaining]
        @setter = save_state[:setter]
        @guesser = save_state[:guesser]
        @word = save_state[:word]
        @hint = save_state[:hint]
    end

    def word_guess(guess)
        if guess == @word.join
            puts "Congratulations #{@guesser.name}, you win!"
            @guesser.points += @guesses_remaining
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
        @guesser.previous_guesses.clear
        if @setter.name != "CPU" && @guesser.name != "CPU"
            temp = @setter
            @setter = @guesser
            @guesser = temp
        end
        @guesses_remaining = 10
        @word = @setter.set_word
        @hint = Array.new(@word.length, " _ ")
        self.guess
    end
end

class Human
    
    attr_accessor :name, :points, :previous_guesses

    def set_word # TODO: stop people setting numbers
        puts "#{@name}, what's your word?"
        word = gets.chomp.downcase.split(//)
        system("clear") || system("cls")
        word
    end

    def guess
        puts "#{@name}, guess a letter or word (or enter 'save' to save the game)"
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
        if @parent.guesses_remaining >= 10
            @valid_guesses = @DICTIONARY.select {|word| word.length == @parent.hint.length}
        end
        if @parent.hint.all?(" _ ")
            @COMMON_LETTERS[@parent.hint.length][10 - @parent.guesses_remaining]
        else
            # change the visible hint to a regex
            hint_string = @parent.hint.join
            hint_pattern = "/#{hint_string.gsub(" _ ", ".")}/"
            # TODO:find the words which match that regex

            # find the most common letter among those and return it
            
        end
    end

    private
    
    def initialize(parent)
        if File.exist?("google-10000-english-no-swears.txt")
            @DICTIONARY = File.open("google-10000-english-no-swears.txt").readlines
        else
            puts "Dictionary is missing"
        end
        # most common letters by word length, guessing all of them guarantees at least one reveal
        @COMMON_LETTERS = [[], %w[a i], %w[a o e i u m b h], %w[a e o i u y h b c k], %w[a e i o u y s b f], %w[s e a o i u y h], %w[e a i o u s y], %w[e i a o u s], %w[e i a o u], %w[e i a o u], %w[e i a o u], %w[e i a o d], %w[e i a o f], %w[i e o a], %w[i e o], %w[i e a], %w[i e h], %w[i e r], %w[i e a], %w[i e a], %w[i e],]
        @name = "CPU"
        @points = 0
        @previous_guesses = Array.new
        @parent = parent
        @valid_guesses = Array.new
    end

    def match_hint?(guess, visible_hints)
        # TODO: return true if it has the same letter as the hint at the same index
    end
end

game = Hangman.new