class Hangman
    def initialize
        @guesses_remaining = 10
        @players = Array.new(2) {|index| self.create_player}
        # TODO: check they don't have the same role
    end

    def create_player
        puts "What's your name? (Enter 'CPU' for CPU player)"
        name = gets.chomp.upcase
        unless name == "CPU"
            name = name.capitalize
        end
        
        puts "Will you guess or set the word?"
        role = gets.chomp.downcase
        if role != "guess" && role != "set"
            puts "***Oops, you made a typo***"
            return self.create_player
        end

        if name == "CPU"
            Computer.new(self, role)
        else
            Human.new(name, role)
        end
    end

    # get guess
        # create an array of equal length to the word, default value "_"

        # print that array and ask the player for a guess

            # also need to print some way of tracking guesses remaining and previously guessed letters

    # get player guess

        # compare it to the randomly chosen word (if it was already guessed, tell them and ask again)

        # reveal all letters that match in the guess array

        # print, then ask for another guess

    # when guesses exceed the allowed amount, end the game and reveal the word

    # maybe save all played games to some kind of log file

    # allow saving at any time

        # if the player enters "save" as their guess, save gamestate info to a file
            # guesses remaining, current revealed letters, previous guesses, player name
end



class Human
    def initialize(name, role)
        @name = name
        @role = role
    end
end


class Computer
    def initialize(parent, role)
        # load the dictionary
        if File.exist?("google-10000-english-no-swears.txt")
            @DICTIONARY = File.open("google-10000-english-no-swears.txt").readlines
        else
            puts "Dictionary is missing"
        end
        @parent = parent
        @role = role
    end

    def choose_word
        valid_words = @DICTIONARY.select {|word| word.length > 4 && word.length < 13}
        word = valid_words[Random.rand(valid_words.length)]
        puts word
    end

    # let the CPU guess a word you set

    # start by guessing from the most common English letters e-t-a-o-i-n-s-h-r-d-l-u 

    # if you want to be a giant nerd have it then check what words from its dictionary abre possible, then the most common letter from those words in the empty space

end

game = Hangman.new