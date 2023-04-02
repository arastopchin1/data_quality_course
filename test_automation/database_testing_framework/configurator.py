import yaml


class Configurator:
    def __init__(self, environment):
        with open("config.yaml") as yaml_file:
            self.config = yaml.safe_load(yaml_file)
        self.config = self.config[environment]
        self.database_url = self.config['database']
        self.test_suits_folder = self.config['test_suits_folder']
