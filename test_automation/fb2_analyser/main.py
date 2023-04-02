"""
Create the application, which should be able to do next:
•	Monitor folder 'input' for files for .fb2 files (if other file exist - move it to 'incorrect_input' folder)
•	Analyze and write in SQLite database results
"""

import logging
import os
import shutil
import sqlite3

from book import Book

logging.basicConfig(level=logging.INFO)


def create_books_definition_table(books, database):
    """
    Func creates the first table from the Task:
    First table is common for all input files and include information about text:
    |book_name|number_of_paragraph|number_of_words|number_of_letters|words_with_capital_letters|words_in_lowercase|
    """
    logging.info(f"Trying to connect to {database}")
    con = sqlite3.connect(database)
    cursor = con.cursor()
    logging.info(f"Successfully connected to {database}")
    logging.info("Creating table books_definition")
    cursor.execute(f"CREATE TABLE books_definition (book_name TEXT, number_of_paragraph INT, number_of_words INT, "
                   f"number_of_letters INT, words_with_capital_letters INT, words_in_lowercase INT)")
    for book in books:
        cursor.execute(
            f"INSERT INTO books_definition VALUES ('{book.name}', {book.paragraphs_count}, {len(book.words)}, "
            f"{book.letters_count}, {book.words_with_capital_letters_count}, {book.words_in_lowercase_count})")
    con.commit()
    logging.info("Books definition table has been successfully created")
    con.close()


def read_files():
    """
    The function check input folder and take all .fb2 files from there.
    Then creates list of Book objects and move not .fb2 files to incorrect directory.
    :return: list of Book objects
    """

    input_folder = './input/'
    incorrect_folder = './incorrect_input/'

    logging.info(f"Read files from {input_folder}")

    files = os.listdir(input_folder)
    books = list()

    if len(files) == 0:
        logging.error("Input folder doesn't contain .fb2 files")

    for file in files:
        if file[-3:] == 'fb2':
            fb2_text = ''
            with open(f'./input/{file}', encoding='UTF-8') as book:
                fb2_text += book.read()
            books.append(Book(file, fb2_text))
            logging.info(f"{file} book has been added to books list")
        else:
            shutil.move(input_folder + f'{file}', incorrect_folder)
            logging.info(f"{file} has been moved to {incorrect_folder}")

    logging.info(f"Reading files from {input_folder} successfully completed")

    return books


if __name__ == '__main__':
    books = read_files()
    for book in books:
        book.create_words_count_table('books.db')
        logging.info(f"Words count table for {book.name} has been created")
    create_books_definition_table(books, 'books.db')
