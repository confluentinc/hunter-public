from dataclasses import dataclass
from typing import Dict

import psycopg2

from hunter.analysis import ChangePoint
from hunter.test_config import PostgresTestConfig


@dataclass
class PostgresConfig:
    hostname: str
    port: int
    username: str
    password: str
    database: str


@dataclass
class PostgresError(Exception):
    message: str


class Postgres:
    __conn = None
    __config = None

    def __init__(self, config: PostgresConfig):
        self.__config = config

    def __get_conn(self) -> psycopg2.extensions.connection:
        if self.__conn is None:
            self.__conn = psycopg2.connect(
                host=self.__config.hostname,
                port=self.__config.port,
                user=self.__config.username,
                password=self.__config.password,
                database=self.__config.database,
            )
        return self.__conn

    def fetch_data(self, query: str):
        cursor = self.__get_conn().cursor()
        cursor.execute(query)
        columns = [c.name for c in cursor.description]
        return (columns, cursor.fetchall())

    def insert_change_point(
        self,
        test: PostgresTestConfig,
        metric_name: str,
        attributes: Dict,
        change_point: ChangePoint,
    ):
        cursor = self.__get_conn().cursor()
        update_stmt = test.update_stmt.format(metric=metric_name, **attributes)
        cursor.execute(
            update_stmt,
            (
                change_point.forward_change_percent(),
                change_point.backward_change_percent(),
                change_point.stats.pvalue,
            ),
        )
        self.__get_conn().commit()
