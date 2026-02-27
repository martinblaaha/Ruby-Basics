vocabulary = [
  'time', 'year', 'people', 'way', 'day', 'man', 'thing', 'woman', 'life', 'friend',
  'child', 'world', 'school', 'state', 'family', 'student', 'group', 'country',
  'problem', 'hand', 'part', 'place', 'case', 'week', 'company', 'system', 'program',
  'question', 'work', 'government', 'number', 'night', 'point', 'home', 'water', 'room',
  'mother', 'area', 'money', 'story', 'fact', 'month', 'lot', 'right', 'study', 'book',
  'eye', 'job', 'word', 'business', 'issue', 'side', 'kind', 'head', 'house', 'service',
  'father', 'power', 'hour', 'game', 'line', 'end', 'member', 'law', 'car', 'city',
  'community', 'name', 'president', 'team', 'minute', 'idea', 'kid', 'body', 'information',
  'back', 'parent', 'face', 'others', 'level', 'office', 'door', 'health', 'person', 'art',
  'war', 'history', 'party', 'result', 'change', 'morning', 'reason', 'research', 'girl',
  'guy', 'moment', 'air', 'teacher', 'force', 'education', 'ametyst', "barrel", "cinnamon",
  "elephant", "fish", "gold", "car", "key", "window", "apple", "pizza", "human", "world"]

def display_word(secret_word, guessed_letters)
  guessed_letters = guessed_letters.map(&:downcase)

  secret_word.chars.map do |letter|
    guessed_letters.include?(letter.downcase) ? letter : "_"
  end.join(" ")
end

def solved?(secret_word, guessed_letters)
  (secret_word.chars.uniq - guessed_letters).empty?
end

###################### START OF PROGRAM ######################
secret_word = vocabulary.sample
guessed_letters = []
wrongly_guessed_letters = []
attempts_left = 10

while attempts_left > 0
  print "Your word: "
  puts display_word(secret_word, guessed_letters)
  puts "Guess a letter:"
  user_guess = gets.chomp

  is_letter_correct = secret_word.include? user_guess
  if is_letter_correct
    print "Nice guess! "
    guessed_letters.push(user_guess)
  else
    unless wrongly_guessed_letters.include?(user_guess)
      wrongly_guessed_letters.push(user_guess)
      attempts_left -= 1
    end
    puts "Unfortunately, that's a miss. Attempts left: #{attempts_left} \nAlready guessed letters:"
    print wrongly_guessed_letters
    print "\n"
  end
  break if solved?(secret_word, guessed_letters)
end

if attempts_left > 0
  puts "YOU WIN!!!"
  print "The word was of course: #{secret_word}"
else
  puts "Almost... Better luck next time!"
  print "The word was: #{secret_word}"
end
