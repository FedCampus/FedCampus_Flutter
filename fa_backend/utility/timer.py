## Do sth. at a specifc time
import time
import datetime
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def getTimeCST(record):
    """
    Input a record. Return a CST time of datetimefield's datetime without timezone information
    """
    return record.update.replace(tzinfo=None) + datetime.timedelta(hours=8)


def cstNow():
    """
    Return a cst time of now without timezone information
    """
    return datetime.datetime.utcnow() + datetime.timedelta(hours=8)


def test():
    print("Hello World!")


def test2():
    print("Hello World222!")


class Alarm:
    """
    Used for calling a function at a specific time of a day
    """

    def __init__(self):
        self.__functionList = []
        self.__ifsend = []
        ## TODO : change ifRefresh to True!
        self.__ifRefresh = True
        pass

    def prepare(self, tupleList):
        """
        prepare functions
        """
        self.__functionList = tupleList
        self.__ifsend = [False for i in self.__functionList]
        pass

    def run(self):
        """
        run the functions in the function list
        """
        while True:
            ## run functions at specific time
            for i, (f, t, arg) in enumerate(self.__functionList):
                now = cstNow()
                functionTime = datetime.datetime(
                    now.year, now.month, now.day, t[0], t[1], t[2]
                )
                if now > functionTime and self.__ifsend[i] == False:
                    logger.info(f"Executing {f} at time {now}")
                    f(*arg)
                    self.__ifsend[i] = True

            ## clear the __ifsend according to the ifRefresh
            if self.__ifRefresh == False:
                for i in range(0, len(self.__ifsend)):
                    self.__ifsend[i] = False
                self.__ifRefresh = True

            ## change the ifRefresh according to the refreshTime
            now = cstNow()
            ## TODO: hard code the refresh time
            refreshTime = datetime.datetime(now.year, now.month, now.day, 1, 0, 0)
            prev = now - datetime.timedelta(seconds=20)
            if prev < refreshTime and now > refreshTime:
                self.__ifRefresh = False
                pass

            time.sleep(10)

    pass


if __name__ == "__main__":
    a = Alarm()
    a.prepare([(test, (9, 43, 0), ()), (test2, (9, 44, 30), ())])
    a.run()
    pass
