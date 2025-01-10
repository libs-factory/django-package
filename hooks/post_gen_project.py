TERMINATOR = "\x1b[0m"
WARNING = "\x1b[1;33m [WARNING]: "
INFO = "\x1b[1;33m [INFO]: "
HINT = "\x1b[3;33m"
SUCCESS = "\x1b[1;32m [SUCCESS]: "

DEBUG_VALUE = "debug"

def main():
    print(SUCCESS + "Project initialized, keep up the good work!" + TERMINATOR)


if __name__ == "__main__":
    main()