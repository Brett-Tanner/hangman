class Hangman
    def initialize
        @guesses_remaining = 10
        @players = Array.new(2) {|index| self.create_player}
        self.same_role?
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
            Computer.new(self, role)
        else
            Human.new(name, role)
        end
    end

    def same_role?
        if @players[0].role == @players[1].role
            puts "***You can't have the same role; #{@players[0].name} choose your role again***"
            @players[0].role = gets.chomp.downcase
            puts "***You can't have the same role; #{@players[1].name} choose your role again***"
            @players[0].role = gets.chomp.downcase
            unless @players.all? {|player| player.role == "guess" || player.role == "guess"}
                self.same_role?
            end
            self.same_role?
        end
    end

    def role?
        
    end

    def set_word
        # get word
        # create an array of equal length to the word, default value "_"

        # print that array and ask the player for a guess

            # also need to print some way of tracking guesses remaining and previously guessed letters
    end

    def guess
        # get guess

        # if the player enters "save" as their guess, save gamestate info to a file
            # guesses remaining, current revealed letters, previous guesses, player name

        # compare it to the randomly chosen word (if it was already guessed, tell them and ask again)

        # reveal all letters that match in the guess array

        # when guesses exceed the allowed amount, end the game and reveal the word

        # print, then ask for another guess
    end

    def end_game
        # maybe save all played games to some kind of log file

    end
    

end



class Human
    
    attr_accessor :role, :name

    private

    def initialize(name, role)
        @name = name
        @role = role
    end
end


class Computer
    
    attr_accessor :role, :name

    private
    
    def initialize(parent, role)
        # load the dictionary
        if File.exist?("google-10000-english-no-swears.txt")
            @DICTIONARY = File.open("google-10000-english-no-swears.txt").readlines
        else
            puts "Dictionary is missing"
        end
        @parent = parent
        @role = role
        @name = "CPU"
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