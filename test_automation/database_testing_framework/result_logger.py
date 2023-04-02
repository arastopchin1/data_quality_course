class ResultLogger:
    def __init__(self):
        self.result_file = open('results/result.log', 'w')

    def start_test(self, suit):
        self.result_file.write(f"Testing of {suit} has been started\n")

    def start_case(self, test_number, test_name):
        self.result_file.write(f"\n --------------------------------------------\n\nTest case number {test_number}: "
                               f"{test_name}\n")

    def add_pass(self, query, actual_result):
        self.result_file.write(f"\nPASSED. Query:\n\n{query}\n\nResult is as expected:\n\n{actual_result}\n\n\t  \n "
                               f"-------------------------------------------- \n")

    def add_fail(self, error, query, actual_result, expected_result):
        self.result_file.write(f"\nFAILED. Query:\n\n{query}\n\nResult is:\n\n{actual_result} \n\nbut expected\n\n"
                               f"{expected_result}\n\nERROR MESSAGE: {error}\n\n"
                               f"--------------------------------------------\n\n")

    def close_logs(self):
        self.result_file.close()
