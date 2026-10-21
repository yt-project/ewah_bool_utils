.. highlight:: shell

============
Contributing
============

Contributions are welcome, and they are greatly appreciated! Every little bit
helps, and credit will always be given. Contributions should follow a standard fork and
pull request workflow and contributors are expected to follow the `yt Community Code
of Conduct <https://github.com/yt-project/yt/blob/main/CONTRIBUTING.rst#yt-community-code-of-conduct>`_
and `Generative AI Policy <https://github.com/yt-project/yt/blob/main/CONTRIBUTING.rst#generative-ai-policy>`_.

Local Development Environment
-----------------------------

Here's how to set up ``ewah_bool_utils`` for local development.
Instructions here rely on `uv <https://docs.astral.sh/uv/>`_ and we highly recommend that you use it too!

1. Fork the ``ewah_bool_utils`` repo on GitHub.
2. Clone your fork locally::

    $ git clone git@github.com:your_name_here/ewah_bool_utils.git

3. Create a ``uv`` virtual environment and first install the build dependencies along with the ``dev``
   and ``test`` dependency groups. The project is built without build isolation, so it needs the
   build dependencies installed first::

    $ uv sync --group dev --group test --no-install-project

4. Now build the package::

    $ uv sync --group dev --group test

5. To check your build, run the test suite::

    $ uv run pytest -v .

6. To continue development, create a branch for local development::

    $ git checkout -b name-of-your-bugfix-or-feature

   Now you can make your changes locally.

7. Rebuild if needed. The install above will create a ``meson-python`` editable installation, and for the most part
   rebuilds should happen automatically when the Cython or C++ sources change. But if you do need to manually rebuild,
   you can run::

    $ uv sync --group dev --group test --reinstall-package ewah-bool-utils

8.  Run tests again::

    $ uv run pytest -v .

9.  Commit your changes and push your branch to GitHub::

    $ git add .
    $ git commit -m "Your detailed description of your changes."
    $ git push origin name-of-your-bugfix-or-feature

10. Submit a pull request through the GitHub website.

