import glob

import pandas as pd

from configurator import Configurator
from connector import Connector
from result_logger import ResultLogger


class TestProcessor:
    def __init__(self, config: Configurator, connector: Connector, logger: ResultLogger):
        self.config = config
        self.connector = connector
        self.logger = logger
        self.test_suits_folder = self.config.test_suits_folder

    def run_test_suit(self, suit):
        self.logger.start_test(suit)
        # logger writes to result.log that testing of the suit has been started

        with open(suit) as suit:
            test_cases = eval(suit.read())
        # suit is .json file which can be converted into python dict using eval()

        for case in test_cases['tests']:
            self.logger.start_case(case['test_number'], case['name'])
            # logger writes to result.log that testing of the case has been started

            query = case['query']
            expected_result = pd.read_csv(case['expected_result_path'])
            actual_result = self.connector.execute(query)

            try:
                pd.testing.assert_frame_equal(expected_result, actual_result, check_dtype=False, check_exact=False)
                self.logger.add_pass(query, actual_result)
            except AssertionError as error:
                self.logger.add_fail(error, query, actual_result, expected_result)

    def run_test_suits(self):
        test_suits = [file for file in glob.glob(self.test_suits_folder + '/*.json', recursive=True)]
        for suit in test_suits:
            self.run_test_suit(suit)
