.. _invocation:

Argbash tools
=============

.. _file_layout:

``Argbash`` is a code generator, so what it does, it gives you code that has the ability to parse command-line arguments.
The question is --- what to do with the generated code?
You have three options here, they are sorted by the estimated preference:

#. One file with both parsing code and script body --- batteries are included!

   This is a both simple and functional approach, but the argument parsing code will pollute your script.

#. Two files --- one for the parsing code and one for the script body, both taken care of by ``Argbash`` --- separation of code, but you get things managed by ``Argbash``..

   This is more suitable for people that prefer to keep things tidy, you can have the parsing code separate and included in the script at run-time.
   However, ``Argbash`` can assist you with that.

#. Same as the above, just without ``Argbash`` assistance --- the parsing code is decoupled from the script.

   You have to take this path if your script has a non-matching square brackets problem (see :ref:`limitations`).
   This approach is similar to the approach of ``bash`` argument parsing libraries with one difference --- here, the library is generated by ``Argbash``, so it may be significantly less complex than those generic libraries such as :ref:`EasyOptions <easy_options>`.
   This is very unlikely.

.. note::

   We assume that you have installed (see :ref:`install`) the ``argbash`` script, so it is available in your terminal as a command ``argbash``.
   If it is not the case, you just have to substitute ``argbash`` by direct invocation of ``bin/argbash``.

.. _argbash_init:

Template generator
------------------

It is not advisable to write a template from scratch, since ``Argbash`` contains a tool for that.
The ``argbash-init`` :ref:`can generate <minimal_example>` a good starting template for you, so you can get started within minutes.

.. _argbash_init_general:

General usage
+++++++++++++

The most efficient way of using ``Argbash`` is probably this one (also covered in an :ref:`example <minimal_example>`):

#. Get an idea of what arguments your script should accept.
#. Execute ``argbash-init`` with the right arguments to get a basic template.
#. Replace placeholders in the template with meaningful values.
#. Expand the template with another directives (if neccessary) based on :ref:`argbash API <argbash_API>`.
#. Run ``argbash`` over the template.

``argbash-init`` supports generating templates with these types of arguments:

* Single-valued positional arguments (``--pos`` argument).
* Single-valued opttional arguments (``--opt`` argument).
* Boolean opttional arguments (``--opt-bool`` argument).

Generally, you specify argument name and you add help etc. by editing the template file.

Next, ``argbash-init`` supports :ref:`wrapping <argbash_wrap>` of another argbash-aware scripts.
The help macro is always included.

.. _argbash_init_modes:

Modes of operation
++++++++++++++++++

``argbash-init`` allows you to select the way how the parsing code is handled (via the ``-s``, ``--standalone`` option):

* Batteries-included mode:

  If you don't specify it, you get the case 1 from above --- the parsing code is embedded in the script.

* Managed mode:

  If you specify it exactly once, you get the case 2 from above --- parsing code is in a separate file, but both files contain ``Argbash`` directives.

* Decoupled mode:

  If you specify twice, you get the case 3 from above --- parsing code is in a separate file, the script includes it without any magic involved.
  This also means that the :ref:`brackets matching limitation <limitations>` doesn't apply to you.

There is also a ``--mode`` option you can use to tune the balance between parsing features and complexity of the generated code.


* ``default``: Assume the standard ``Argbash`` behavior.
  Check the documentation out to find out what that means.

* ``full``: Maximize script features.
  * The long option and the corresponding value may be separated by whitespace or by the equal sign.
  * Variables corresponding to every positional argument is declared (.. seealso::`_declare_pos`).

* ``minimal``: Make the code as simple as possible, which means:
  * The long option and the corresponding value may be separated only by whitespace.


Argbash
-------

So, you have a template and now it is time to (re)generate a shell script from it!

Parsing code and script body together
+++++++++++++++++++++++++++++++++++++

Assuming that you have created a template file ``my-template.m4``, you simply run ``argbash`` over the script [*]_:

::

   argbash my-template.m4 -o my-script.sh

If you want to regenerate a new version of ``my-script.sh`` after you have modified its template section, you can run

::

   argbash my-script.sh -o my-script.sh

as the script can deal with input and output being the same file.

.. [*] ``m4`` is the file extension used for the ``M4`` language, but we use the ``m4sugar`` language extension built on top of it.

Separate file for parsing with assistance
+++++++++++++++++++++++++++++++++++++++++

You have two files, let's say it is a ``my-parsing.m4`` and ``my-script.sh``.
The ``my-parsing.m4`` file contains just the template section of ``my-script.sh``.
Then, you add a very small template code to ``my-script.sh`` at the beginning:

.. code-block:: bash

    # DEFINE_SCRIPT_DIR
    # INCLUDE_PARSING_CODE([my-parsing.sh])
    # ARGBASH_GO

    # [ <-- needed because of Argbash

    # HERE GOES THE SCRIPT BODY

    # ] <-- needed because of Argbash

i.e. you add thos three lines with definitions and you enclose the script in square brackets.

Finally, you just make sure that ``my-script.sh`` and ``my-parsing.m4`` are next to each other and run

::

   argbash my-script.sh -o my-script.sh

which finds ``my-parsing.m4`` (it would find ``my-parsing.sh`` too) and generates new ``my-parsing.sh`` and ``my-script.sh`` that you can use right away.
If both ``my-parsing.m4`` and ``my-parsing.sh`` are found, the more recent one is used to generate the ``my-parsing.sh``.

.. _usage_manual:

Separate file for parsing
+++++++++++++++++++++++++

If you want/have to take care of including the parsing code yourself, just make sure you do it in the script --- for example:

.. code-block:: bash

    source $(dirname $0)/my-parsing.sh

    # HERE GOES THE SCRIPT BODY

Then, you just generate ``my-parsing.sh`` using ``--library`` option:

.. code-block:: bash

   argbash my-parsing.m4 -o my-parsing.sh --library

.. _api_change:

API changes support
-------------------

The API of the ``Argbash`` project may change.
This typically means that

* names, parameters or effect of macros change, or
* parsed arguments are exposed differently

in a way that is not compatible with the previous API.

In case that you regenerate a script, ``argbash`` is able to deduce that it has been created with another version of ``Argbash`` and warns you.
In that case, you can use a ``argbash-xtoy`` script, where ``x`` is the version of ``Argbash`` your script is written for and ``y`` is version of ``Argbash`` you use now.

To upgrade your script from ``Argbash`` version 1 to 2, you simply invoke:

.. code-block:: bash

   argbash-1to2 my-script.sh -o my-script.sh

You can use the utility to convert scripts as well as ``.m4`` templates.

.. warning::

   Always back your scripts up and perform diff between the output and the original after using ``argbash-xtoy``.

API 2
+++++

Parsed arguments were exposed as lowercase (``_ARG_LONG_OPTION`` became ``_arg_long_option``).
The change was motivated by effort to comply to bash standard variable naming convention [#]_, [#]_.

.. [#] `Unix StackExchange <http://unix.stackexchange.com/a/42849>`_
.. [#] `Google bash styleguide <https://google.github.io/styleguide/shell.xml#Naming_Conventions>`_
