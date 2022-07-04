# Copyright (C) 2022, Michael Fabian 'Xaymar' Dirks <info@xaymar.com>. All Rights Reserved
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#[=======================================================================[.rst:
version
-------

Generate, parse and modify versions purely with CMake. Supports Semantic Versioning 2.0.0, 1.0.0 and other version formats.

Synopsis
^^^^^^^^

.. parsed-literal::

  version(`PARSE`_ <out-var> <string>)
  version(`GENERATE`_ <out-var> [COMPRESS] [MAJOR <major>] [MINOR <minor>] [PATCH <patch>] [TWEAK <tweak>] [PRERELEASE <prerelease>] [BUILD <build>])
  version(`MODIFY`_ <out-var> <string> [COMPRESS] [MAJOR <major>] [MINOR <minor] [PATCH <patch>] [TWEAK <tweak>] [PRERELEASE <prerelease>] [BUILD <build>])
  version(`COMPARE`_ <out-var> <a> <b>)


The following version constructs are currently supported:

.. code-block::

  <major> "." <minor> ["." <patch> ["." <tweak>]]
  <major> "." <minor> ["." <patch> ["." <tweak>]] [["-"] <pre-release>] ["+" <build>]


Parsing
^^^^^^^

.. _PARSE:

.. code-block:: cmake

  version(PARSE <out-var> <string>)

Attempts to parse the version in ``<string>`` and stores the individual compoents into ``<out-var>_<component>``. If a component is not present in the given version, it will be undefined. If an error occurred, ``<out-var>_ERROR`` will be defined and contain the error message.

Generating
^^^^^^^^^^

.. _GENERATE:

.. code-block:: cmake

  version(GENERATE <out-var> [COMPRESS] [MAJOR <major>] [MINOR <minor>] [PATCH <patch>] [TWEAK <tweak>] [PRERELEASE <prerelease>] [BUILD <build>])

Generates a version from the components provided and stores the result in ``<out-var>``. The components ``<major>`` and ``<minor>`` will default to ``0`` if not provided. If an error occurred, ``<out-var>_ERROR`` will be defined and contain the error message.

Modifying
^^^^^^^^^

.. _MODIFY:

.. code-block:: cmake

  version(MODIFY <out-var> <string> [COMPRESS] [MAJOR <major>] [MINOR <minor] [PATCH <patch>] [TWEAK <tweak>] [PRERELEASE <prerelease>] [BUILD <build>])

Modifies the version provided in ``<string>`` with the components provided. The components ``<major>``, ``<minor>``, ``<patch>`` and ``<tweak>`` may have a prefix of ``+`` or ``-`` to add and subtract the value, or no prefix to replace. The result of this operation will be stored as a string in ``<out-var>``. If a component did not exist in the original, it will be added to the version as a replace operation. If an error occurred, ``<out-var>_ERROR`` will be defined and contain the error message.

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
- In all other cases, ``<out-var>`` will be empty.
- If an error occurred, ``<out-var>_ERROR`` will be defined and contain the error message, and ``<out-var>`` will be undefined. 
#]=======================================================================]

function(version)
	# CMake functions do not have their own proper scope, they act more 

	set(OUT_VAR "${ARGV1}")

	# Force clean parent elements.
	set(${OUT_VAR} "" PARENT_SCOPE)
	set(${OUT_VAR}_ERROR "" PARENT_SCOPE)

	string(TOUPPER "${ARGV0}" ARGV0)
	if(ARGV0 STREQUAL "PARSE")
		# <major> "." <minor> ["." <patch> ["." <tweak>]]
		# <major> "." <minor> ["." <patch> ["." <tweak>]] [["-"] <pre-release>] ["+" <build>]

		# One regex to rule them all...
		if(NOT (ARGV2 MATCHES [[^([0-9]+)\.([0-9]+)(\.[0-9]+|)(\.[0-9]+|)(-?[a-zA-Z0-9]+[a-zA-Z0-9\.\-]*|)(\+[a-zA-Z0-9]+[a-zA-Z0-9\.\-]*|)$]]))
			set(${OUT_VAR}_ERROR "Version format not supported: '${ARGV2}'" PARENT_SCOPE)
			return()
		endif()

		# {1} = Major
		set(${OUT_VAR}_MAJOR "${CMAKE_MATCH_1}" PARENT_SCOPE)
		# {2} = Minor
		set(${OUT_VAR}_MINOR "${CMAKE_MATCH_2}" PARENT_SCOPE)
		# {3} = Patch
		if(CMAKE_MATCH_3)
			string(SUBSTRING "${CMAKE_MATCH_3}" 1 -1 _TMP)
			set(${OUT_VAR}_PATCH "${_TMP}" PARENT_SCOPE)
		else()
			set(${OUT_VAR}_PATCH "" PARENT_SCOPE)
		endif()
		# {4} = Tweak
		if(CMAKE_MATCH_4)
			string(SUBSTRING "${CMAKE_MATCH_4}" 1 -1 _TMP)
			set(${OUT_VAR}_TWEAK "${_TMP}" PARENT_SCOPE)
		else()
			set(${OUT_VAR}_TWEAK "" PARENT_SCOPE)
		endif()
		# {5} = PreRelease
		if(CMAKE_MATCH_5)
			string(REPLACE "." ";" CMAKE_MATCH_5 "${CMAKE_MATCH_5}") # Handle dot separation as list.
			string(SUBSTRING "${CMAKE_MATCH_5}" 0 1 _TMP)
			if(_TMP STREQUAL "-")
				string(SUBSTRING "${CMAKE_MATCH_5}" 1 -1 CMAKE_MATCH_5)
				set(${OUT_VAR}_PRERELEASE "${CMAKE_MATCH_5}" PARENT_SCOPE)
			else()
				set(${OUT_VAR}_PRERELEASE "${CMAKE_MATCH_5}" PARENT_SCOPE)
			endif()
		else()
			set(${OUT_VAR}_PRERELEASE "" PARENT_SCOPE)
		endif()
		# {6} = Build
		if(CMAKE_MATCH_6)
			string(REPLACE "." ";" CMAKE_MATCH_6 "${CMAKE_MATCH_6}") # Handle dot separation as list.
			string(SUBSTRING "${CMAKE_MATCH_6}" 1 -1 CMAKE_MATCH_6)
			set(${OUT_VAR}_BUILD "${CMAKE_MATCH_6}" PARENT_SCOPE)
		else()
			set(${OUT_VAR}_BUILD "" PARENT_SCOPE)
		endif()
	elseif(ARGV0 STREQUAL "GENERATE")
		set(_feeb1eff "")
		set(_32070faa "")
		set(_32070faa_MAJOR "")
		set(_32070faa_MINOR "")
		set(_32070faa_PATCH "")
		set(_32070faa_TWEAK "")
		set(_32070faa_PRERELEASE "")
		set(_32070faa_BUILD "")
		set(_32070faa_ERROR "")
		cmake_parse_arguments(
			PARSE_ARGV 2
			_32070faa
			"COMPRESS"
			"MAJOR;MINOR;PATCH;TWEAK;PRERELEASE;BUILD"
			""
		)

		# Do we have the major component, and is it valid?
		if(_32070faa_MAJOR)
			string(STRIP "${_32070faa_MAJOR}" _32070faa_MAJOR)
			if(_32070faa_MAJOR STREQUAL "")
				set(_32070faa_MAJOR 0)
			elseif(NOT (_32070faa_MAJOR MATCHES [[^[0-9]+$]]))
				set(${OUT_VAR}_ERROR "MAJOR component must be a numeric identifier, but is: '${_32070faa_MAJOR}'" PARENT_SCOPE)
				return()
			endif()
		else()
			set(_32070faa_MAJOR 0)
		endif()
		set(_feeb1eff "${_feeb1eff}${_32070faa_MAJOR}")

		# Do we have the minor component, and is it valid?
		if(_32070faa_MINOR)
			string(STRIP "${_32070faa_MINOR}" _32070faa_MINOR)
			if(_32070faa_MINOR STREQUAL "")
				set(_32070faa_MINOR 0)
			elseif(NOT (_32070faa_MINOR MATCHES [[^[0-9]+$]]))
				set(${OUT_VAR}_ERROR "MINOR component must be a numeric identifier, but is: '${_32070faa_MINOR}'" PARENT_SCOPE)
				return()
			endif()
		else()
			set(_32070faa_MINOR 0)
		endif()
		set(_feeb1eff "${_feeb1eff}.${_32070faa_MINOR}")

		# Do we have the patch component, and is it valid?
		if(_32070faa_PATCH)
			string(STRIP "${_32070faa_PATCH}" _32070faa_PATCH)
			if(_32070faa_PATCH STREQUAL "")
				unset(_32070faa_PATCH)
			elseif(_32070faa_PATCH MATCHES [[^[0-9]+$]])
				set(_feeb1eff "${_feeb1eff}.${_32070faa_PATCH}")
			else()
				set(${OUT_VAR}_ERROR "PATCH component must be a numeric identifier, but is: '${_32070faa_PATCH}'" PARENT_SCOPE)
				return()
			endif()
		endif()

		# Do we have the tweak component, and is it valid?
		if(_32070faa_TWEAK)
			string(STRIP "${_32070faa_TWEAK}" _32070faa_TWEAK)
			if(_32070faa_TWEAK STREQUAL "")
				unset(_32070faa_TWEAK)
			elseif(_32070faa_TWEAK MATCHES [[^[0-9]+$]])
				if(NOT _32070faa_PATCH)
					set(_feeb1eff "${_feeb1eff}.0")
				endif()
				set(_feeb1eff "${_feeb1eff}.${_32070faa_TWEAK}")
			else()
				set(${OUT_VAR}_ERROR "TWEAK component must be a numeric identifier, but is: '${_32070faa_TWEAK}'" PARENT_SCOPE)
				return()
			endif()
		endif()

		# Do we have the pre-release component, and is it valid?
		if(_32070faa_PRERELEASE)
			string(STRIP "${_32070faa_PRERELEASE}" _32070faa_PRERELEASE)
			list(JOIN _32070faa_PRERELEASE "." _32070faa_PRERELEASE)
			if(_32070faa_PRERELEASE STREQUAL "")
				unset(_32070faa_PRERELEASE)
			elseif(_32070faa_PRERELEASE MATCHES [[^[a-zA-Z0-9]+[a-zA-Z0-9\-\.]*$]])
				if(_32070faa_COMPRESS AND (_32070faa_PRERELEASE MATCHES [[[a-zA-Z]+[a-zA-Z0-9\-\.]*$]]))
					set(_feeb1eff "${_feeb1eff}${_32070faa_PRERELEASE}")
				else()
					set(_feeb1eff "${_feeb1eff}-${_32070faa_PRERELEASE}")
				endif()
			else()
				set(${OUT_VAR}_ERROR "PRERELEASE component must be an alphanumeric identifier, but is: '${_32070faa_PRERELEASE}'" PARENT_SCOPE)
				return()
			endif()
		endif()

		# Do we have the build component, and is it valid?
		if(_32070faa_BUILD)
			string(STRIP "${_32070faa_BUILD}" _32070faa_PRERELEASE)
			list(JOIN _32070faa_BUILD "." _32070faa_BUILD)
			if(_32070faa_BUILD STREQUAL "")
				unset(_32070faa_BUILD)
			elseif(_32070faa_BUILD MATCHES [[^[a-zA-Z0-9]+[a-zA-Z0-9\-\.]*$]])
				set(_feeb1eff "${_feeb1eff}+${_32070faa_BUILD}")
			else()
				set(${OUT_VAR}_ERROR "BUILD component must be an alphanumeric identifier, but is: '${_32070faa_BUILD}'" PARENT_SCOPE)
				return()
			endif()
		endif()

		set(${OUT_VAR} "${_feeb1eff}" PARENT_SCOPE)
	elseif(ARGV0 STREQUAL "MODIFY")
		# Requires PARSE and GENERATE.
		set(_fe7bcddd "")
		set(_fe7bcddd_MAJOR "")
		set(_fe7bcddd_MINOR "")
		set(_fe7bcddd_PATCH "")
		set(_fe7bcddd_TWEAK "")
		set(_fe7bcddd_PRERELEASE "")
		set(_fe7bcddd_BUILD "")
		set(_fe7bcddd_ERROR "")
		cmake_parse_arguments(
			PARSE_ARGV 3
			_fe7bcddd
			"COMPRESS"
			"MAJOR;MINOR;PATCH;TWEAK;PRERELEASE;BUILD"
			""
		)

		# Helpers
		macro(modify_version_number)
			if(${ARGV1})
				if(${ARGV1} MATCHES "^(\\+|\\-)([0-9]+)$")
					if(${ARGV0})
						math(EXPR ${ARGV0} "${${ARGV0}} ${CMAKE_MATCH_1} ${CMAKE_MATCH_2}")
					else()
						math(EXPR ${ARGV0} "0 ${CMAKE_MATCH_1} ${CMAKE_MATCH_2}")
					endif()
				else()
					set(${ARGV0} "${${ARGV1}}")
				endif()
			endif()
		endmacro()

		# Parse the given version.
		set(_df8abcce "")
		set(_df8abcce_MAJOR "")
		set(_df8abcce_MINOR "")
		set(_df8abcce_PATCH "")
		set(_df8abcce_TWEAK "")
		set(_df8abcce_PRERELEASE "")
		set(_df8abcce_BUILD "")
		set(_df8abcce_ERROR "")
		version(PARSE _df8abcce "${ARGV2}")
		if(_df8abcce_ERROR)
			set(${OUT_VAR}_ERROR ${_df8abcce_ERROR} PARENT_SCOPE)
			return()
		endif()

		# Modify core version components
		modify_version_number(_df8abcce_MAJOR _fe7bcddd_MAJOR)
		modify_version_number(_df8abcce_MINOR _fe7bcddd_MINOR)
		modify_version_number(_df8abcce_PATCH _fe7bcddd_PATCH)
		modify_version_number(_df8abcce_TWEAK _fe7bcddd_TWEAK)

		# Replace other components if defined.
		if(_fe7bcddd_PRERELEASE)
			set(_df8abcce_PRERELEASE "${_fe7bcddd_PRERELEASE}")
		endif()
		if(_fe7bcddd_BUILD)
			set(_df8abcce_BUILD "${_fe7bcddd_BUILD}")
		endif()

		# Generate a new version.
		set(_fe7bcddd_GEN "")
		if(_df8abcce_MAJOR AND (NOT _df8abcce_MAJOR STREQUAL ""))
			set(_fe7bcddd_GEN "${_fe7bcddd_GEN} MAJOR \"${_df8abcce_MAJOR}\"")
		endif()
		if(_df8abcce_MINOR AND (NOT _df8abcce_MINOR STREQUAL ""))
			set(_fe7bcddd_GEN "${_fe7bcddd_GEN} MINOR \"${_df8abcce_MINOR}\"")
		endif()
		if(_df8abcce_PATCH AND (NOT _df8abcce_PATCH STREQUAL ""))
			set(_fe7bcddd_GEN "${_fe7bcddd_GEN} PATCH \"${_df8abcce_PATCH}\"")
		endif()
		if(_df8abcce_TWEAK AND (NOT _df8abcce_TWEAK STREQUAL ""))
			set(_fe7bcddd_GEN "${_fe7bcddd_GEN} TWEAK \"${_df8abcce_TWEAK}\"")
		endif()
		if(_df8abcce_PRERELEASE AND (NOT _df8abcce_PRERELEASE STREQUAL ""))
			set(_fe7bcddd_GEN "${_fe7bcddd_GEN} PRERELEASE \"${_df8abcce_PRERELEASE}\"")
		endif()
		if(_df8abcce_BUILD AND (NOT _df8abcce_BUILD STREQUAL ""))
			set(_fe7bcddd_GEN "${_fe7bcddd_GEN} BUILD \"${_df8abcce_BUILD}\"")
		endif()
		if(_fe7bcddd_COMPRESS)
			set(_fe7bcddd_GEN "${_fe7bcddd_GEN} COMPRESS")
		endif()
		cmake_language(EVAL CODE "version(GENERATE _df8abcce ${_fe7bcddd_GEN})")
		if(_df8abcce_ERROR)
			set(${OUT_VAR}_ERROR ${_df8abcce_ERROR} PARENT_SCOPE)
			return()
		endif()
		set(${OUT_VAR} "${_df8abcce}" PARENT_SCOPE)
	elseif(ARGV0 STREQUAL "COMPARE")
		# Requires PARSE.

		# Parse first version
		set(_00fdeadb "")
		set(_00fdeadb_MAJOR "")
		set(_00fdeadb_MINOR "")
		set(_00fdeadb_PATCH "")
		set(_00fdeadb_TWEAK "")
		set(_00fdeadb_PRERELEASE "")
		set(_00fdeadb_BUILD "")
		set(_00fdeadb_ERROR "")
		version(PARSE _00fdeadb "${ARGV2}")
		if(_00fdeadb_ERROR)
			set(${OUT_VAR}_ERROR ${_00fdeadb_ERROR} PARENT_SCOPE)
			return()
		endif()

		# Parse second version
		set(_ca75feel "")
		set(_ca75feel_MAJOR "")
		set(_ca75feel_MINOR "")
		set(_ca75feel_PATCH "")
		set(_ca75feel_TWEAK "")
		set(_ca75feel_PRERELEASE "")
		set(_ca75feel_BUILD "")
		set(_ca75feel_ERROR "")
		version(PARSE _ca75feel "${ARGV3}")
		if(_ca75feel_ERROR)
			set(${OUT_VAR}_ERROR ${_ca75feel_ERROR} PARENT_SCOPE)
			return()
		endif()

		# Major
		if(_00fdeadb_MAJOR GREATER _ca75feel_MAJOR)
			set(${OUT_VAR} ">MAJOR" PARENT_SCOPE)
			return()
		elseif(_00fdeadb_MAJOR LESS _ca75feel_MAJOR)
			set(${OUT_VAR} "<MAJOR" PARENT_SCOPE)
			return()
		endif()

		# Minor
		if(_00fdeadb_MINOR GREATER _ca75feel_MINOR)
			set(${OUT_VAR} ">MINOR" PARENT_SCOPE)
			return()
		elseif(_00fdeadb_MINOR LESS _ca75feel_MINOR)
			set(${OUT_VAR} "<MINOR" PARENT_SCOPE)
			return()
		endif()

		# Patch
		if(_00fdeadb_PATCH GREATER _ca75feel_PATCH)
			set(${OUT_VAR} ">PATCH" PARENT_SCOPE)
			return()
		elseif(_00fdeadb_PATCH LESS _ca75feel_PATCH)
			set(${OUT_VAR} "<PATCH" PARENT_SCOPE)
			return()
		elseif((_00fdeadb_PATCH STREQUAL "") OR (_ca75feel_PATCH STREQUAL ""))
			if(_00fdeadb_PATCH)
				set(${OUT_VAR} "+PATCH" PARENT_SCOPE)
				return()
			elseif(_ca75feel_PATCH)
				set(${OUT_VAR} "-PATCH" PARENT_SCOPE)
				return()
			endif()
		endif()

		# Tweak
		if(_00fdeadb_TWEAK GREATER _ca75feel_TWEAK)
			set(${OUT_VAR} ">TWEAK" PARENT_SCOPE)
			return()
		elseif(_00fdeadb_TWEAK LESS _ca75feel_TWEAK)
			set(${OUT_VAR} "<TWEAK" PARENT_SCOPE)
			return()
		elseif((_00fdeadb_TWEAK STREQUAL "") OR (_ca75feel_TWEAK STREQUAL ""))
			if(_00fdeadb_TWEAK)
				set(${OUT_VAR} "+TWEAK" PARENT_SCOPE)
				return()
			elseif(_ca75feel_TWEAK)
				set(${OUT_VAR} "-TWEAK" PARENT_SCOPE)
				return()
			endif()
		endif()

		# Pre-Release
		if((_00fdeadb_PRERELEASE STREQUAL "") OR (_ca75feel_PRERELEASE STREQUAL ""))
			if(_00fdeadb_PRERELEASE)
				set(${OUT_VAR} "+PRERELEASE" PARENT_SCOPE)
				return()
			elseif(_ca75feel_PRERELEASE)
				set(${OUT_VAR} "-PRERELEASE" PARENT_SCOPE)
				return()
			endif()
		elseif(NOT (_00fdeadb_PRERELEASE STREQUAL _ca75feel_PRERELEASE))
			set(${OUT_VAR} "PRERELEASE" PARENT_SCOPE)
			return()		
		endif()

		# Build
		if((_00fdeadb_BUILD STREQUAL "") OR (_ca75feel_BUILD STREQUAL ""))
			if(_00fdeadb_BUILD)
				set(${OUT_VAR} "+BUILD" PARENT_SCOPE)
				return()
			elseif(_ca75feel_BUILD)
				set(${OUT_VAR} "-BUILD" PARENT_SCOPE)
				return()
			endif()
		elseif(NOT (_00fdeadb_BUILD STREQUAL _ca75feel_BUILD))
			set(${OUT_VAR} "BUILD" PARENT_SCOPE)
			return()		
		endif()

		# Both are exactly the same.
		set(${OUT_VAR} "" PARENT_SCOPE)
	else()
		message(FATAL_ERROR "Unknown command '${ARGV0}'")
		return()
	endif()
endfunction()