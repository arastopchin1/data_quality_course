import logging
import re
import sqlite3


class Book:
    def __init__(self, file_name, fb2_text):
        self.file_name = file_name[:-4]  # file name with format .fb2
        self.name = re.findall('<book-title>(.+)</book-title>', fb2_text)[0]  # book title
        self.start_body_index = (re.search('<body>', fb2_text)).end()  # start <body> position
        self.end_body_index = re.search('</body>', fb2_text).start()  # end </body> position
        self.body_text = fb2_text[self.start_body_index:self.end_body_index]  # text inside body
        self.paragraphs_count = len(re.findall('<p>(.+)</p>', self.body_text))  # count of paragraphs
        self.clean_text = re.sub('<.+?>', '', self.body_text)  # text without markup
        self.words = re.split('\\W+', self.clean_text)  # all words in the clean text
        self.letters_count = len(re.sub('\\W', '', self.clean_text))  # count of letters
        self.word_number_dict = dict()  # words and count of its appearance, and count of uppercase in the word

        '''
        structure of word_number_dict is {word: [count_of_words, count_of_uppercase_in_word]}
        '''

        for word in self.words:
            if word in self.word_number_dict:
                self.word_number_dict[word][0] += 1
            else:
                uppercase_count = 0
                for letter in word:
                    if letter.isupper():
                        uppercase_count += 1
                self.word_number_dict[word] = [1, uppercase_count]

        self.words_with_capital_letters_count = 0
        for key in self.word_number_dict:
            if self.word_number_dict[key][1] != 0:
                self.words_with_capital_letters_count += self.word_number_dict[key][0]

        self.words_in_lowercase_count = 0
        for key in self.word_number_dict:
            if self.word_number_dict[key][1] == 0:
                self.words_in_lowercase_count += self.word_number_dict[key][0]

    def create_words_count_table(self, database):
        """
        Func creates the second table from the Task:
        Second table is personal for each input file and should include frequency of each word from input file:
        | word	| count	 | count_uppercase |
        """
        logging.info(f"Trying to connect to {database}")
        con = sqlite3.connect(database)
        cursor = con.cursor()
        logging.info(f"Successfully connected to {database}")
        logging.info(f"Creating table {self.file_name}_words")

        cursor.execute(f"CREATE TABLE {self.file_name}_words (word TEXT, count INT, count_uppercase INT)")
        logging.info(f"{self.file_name}_words table has been successfully created")

        for key in self.word_number_dict:
            cursor.execute(
                f"INSERT INTO {self.file_name}_words VALUES ('{key}', "
                f"{self.word_number_dict[key][0]}, {self.word_number_dict[key][1]})")
        con.commit()
        con.close()
