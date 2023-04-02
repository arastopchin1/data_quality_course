"""
This class establish connection to database
"""

import pandas as pd
from sqlalchemy import create_engine, engine


class Connector:
    def __init__(self, database_url):
        self.engine: engine = create_engine(f'sqlite:///{database_url}')

    def execute(self, query):
        with self.engine.connect():
            table = pd.read_sql_query(query, self.engine)
        return table
