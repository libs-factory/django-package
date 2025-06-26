import os
import shutil
import re

TERMINATOR = "\x1b[0m"
WARNING = "\x1b[1;33m [WARNING]: "
INFO = "\x1b[1;33m [INFO]: "
HINT = "\x1b[3;33m"
SUCCESS = "\x1b[1;32m [SUCCESS]: "

DEBUG_VALUE = "debug"

def remove_cypress_files():
    """Remove Cypress E2E test files if not selected"""
    if "{{ cookiecutter.use_cypress }}" != "y":
        e2e_dir = os.path.join(os.getcwd(), "tests", "e2e")
        if os.path.exists(e2e_dir):
            shutil.rmtree(e2e_dir)
            print(INFO + "Removed E2E test files (Cypress not selected)" + TERMINATOR)

def main():
    remove_cypress_files()
    print(SUCCESS + "Project initialized, keep up the good work!" + TERMINATOR)


if __name__ == "__main__":
    main()