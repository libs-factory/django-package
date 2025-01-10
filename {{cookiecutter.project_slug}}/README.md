# {{cookiecutter.project_name}}

{{cookiecutter.description}}

## Development guide

First, install the required dependencies:

- Install Pyenv and Python 3.12:

```bash
curl https://pyenv.run | bash

pyenv install 3.12
```

- Create a virtual environment:

```bash
cd {{cookiecutter.project_slug}}

make dev
```

- Enjoy!
