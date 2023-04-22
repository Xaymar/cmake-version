version
-------

Generate, parse and modify versions purely with CMake. Supports Semantic Versioning 2.0.0, 1.0.0 and other version formats.

Synopsis
^^^^^^^^

.. parsed-literal::

  version(`PARSE`_ <out-var> [REQUIRE [PATCH|TWEAK][;...]] <string>)
  version(`GENERATE`_ <out-var> [COMPRESS] [MAJOR <major>] [MINOR <minor>] [PATCH <patch>] [TWEAK <tweak>] [PRERELEASE <prerelease>] [BUILD <build>] [REQUIRE [PATCH|TWEAK][;...]])
  version(`MODIFY`_ <out-var> <string> [COMPRESS] [MAJOR <major>] [MINOR <minor] [PATCH <patch>] [TWEAK <tweak>] [PRERELEASE <prerelease>] [BUILD <build>] [REQUIRE [PATCH|TWEAK][;...]])
  version(`COMPARE`_ <out-var> <a> <b>)


The following version constructs are currently supported:

.. code-block::

  <major> "." <minor> ["." <patch> ["." <tweak>]] [["-"] <pre-release> ["." <pre-release> [...]]] ["+" <build> ["." <build> [...]]]

Parsing
^^^^^^^

.. _PARSE:

.. code-block:: cmake

  version(PARSE <out-var> [REQUIRE [PATCH|TWEAK][;...]] <string>)

Attempts to parse the version in ``<string>`` and stores the individual compoents into ``<out-var>_<component>``. If a component is not present in the given version, it will be set to a false constant. If an error occurred, ``<out-var>_ERROR`` will contain the error message otherwise it will be a false constant. The ``PRERELEASE`` and ``BUILD`` components support the dot-separation specifier and will be turned into a list if they are encountered. The optional ``REQUIRE`` allows forcing the components ``PATCH`` and ``TWEAK`` to always be defined.

It is necessary to include a ``;`` for the ``REQUIRE`` parameter, even if there is only one required part. 

Generating
^^^^^^^^^^

.. _GENERATE:

.. code-block:: cmake

  version(GENERATE <out-var> [COMPRESS] [MAJOR <major>] [MINOR <minor>] [PATCH <patch>] [TWEAK <tweak>] [PRERELEASE <prerelease>] [BUILD <build>] [REQUIRE [PATCH|TWEAK][;...]])

Generates a version from the components provided and stores the result in ``<out-var>``. The components ``<major>`` and ``<minor>`` will default to ``0`` if not provided. If an error occurred,  ``<out-var>_ERROR`` will contain the error message otherwise it will be a false constant. The ``PRERELEASE`` and ``BUILD`` components support the dot-separation specifier and will be converted from a list if encountered. The optional ``REQUIRE`` allows forcing the components ``PATCH`` and ``TWEAK`` to always be defined.

It is necessary to include a ``;`` for the ``REQUIRE`` parameter, even if there is only one required part. 

Modifying
^^^^^^^^^

.. _MODIFY:

.. code-block:: cmake

  version(MODIFY <out-var> <string> [COMPRESS] [MAJOR <major>] [MINOR <minor] [PATCH <patch>] [TWEAK <tweak>] [PRERELEASE <prerelease>] [BUILD <build>] [REQUIRE [PATCH|TWEAK][;...]])

Modifies the version provided in ``<string>`` with the components provided. The components ``<major>``, ``<minor>``, ``<patch>`` and ``<tweak>`` may have a prefix of ``+`` or ``-`` to add and subtract the value, or no prefix to replace. The result of this operation will be stored as a string in ``<out-var>``. If a component did not exist in the original, it will be added to the version as a replace operation. If an error occurred,  ``<out-var>_ERROR`` will contain the error message otherwise it will be a false constant. The optional ``REQUIRE`` allows forcing the components ``PATCH`` and ``TWEAK`` to always be defined.

It is necessary to include a ``;`` for the ``REQUIRE`` parameter, even if there is only one required part. 

Comparing
^^^^^^^^^

.. _COMPARE:

.. code-block:: cmake

  version(COMPARE <out-var> <a> <b>)

Compares the version ``<a>`` against ``<b>`` and stores the result in ``<out-var>``. The provided version will be evaluated in the order MAJOR, MINOR, PATCH, TWEAK, PRERELEASE, and then BUILD. The following results should be expected:

- If a component is only in ``<a>``, ``<out-var>`` will contain the componenent name prefixed by ``+``.
- If a component is only in ``<b>``, ``<out-var>`` will contain the componenent name prefixed by ``-``.
- If a component is numerical and the value is larger in ``<a>``, ``<out-var>`` will contain the componenent name prefixed by ``>``.
- If a component is numerical and the value is larger in ``<b>``, ``<out-var>`` will contain the componenent name prefixed by ``<``.
- If a component is alphanumerical and the value is different in either, ``<out-var>`` will contain the component name with no prefix.
- If an error occurred,  ``<out-var>_ERROR`` will contain the error message otherwise it will be a false constant, and ``<out-var>`` will be a false constant.
- In all other cases, ``<out-var>`` will be a false constant.

There is no special handling for dot-separated ``PRERELEASE`` and ``BUILD`` component. They will be treated as if they were a string, as special handling for these is up to the application.
