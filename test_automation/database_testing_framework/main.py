"""
This program perform database testing.
Program gets an environment as a parameter from the command line e.g. dev, uat etc.
For this type of environment the program gets Database url and test suits folder from config.yaml file.
Program establish connection to database and perform all test suits which stored as .json files.
In each test suit .json file contains a number of test cases.
"""

from sys import argv

from configurator import Configurator
from connector import Connector
from result_logger import ResultLogger
from test_processor import TestProcessor


def run_tests():
    config = Configurator(argv[1])
    # environment is passed as an argument from the command line (dev, uat, etc.)

    database_url = config.database_url
    # using config file we get database_url for establishing connection

    connector = Connector(database_url=database_url)
    # establish connection

    logger = ResultLogger()
    test_processor = TestProcessor(config=config, connector=connector, logger=logger)
    test_processor.run_test_suits()
    logger.close_logs()


if __name__ == "__main__":
    run_tests()
