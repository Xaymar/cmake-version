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

# For SemVer 2.0.0

function(version)
	unset(${OUT_VAR} PARENT_SCOPE)
	unset(${OUT_VAR}_ERROR PARENT_SCOPE)
	set(OUT_VAR "${ARGV1}")
	set(_ "")

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
			unset(${OUT_VAR}_PATCH PARENT_SCOPE)
		endif()
		# {4} = Tweak
		if(CMAKE_MATCH_4)
			string(SUBSTRING "${CMAKE_MATCH_4}" 1 -1 _TMP)
			set(${OUT_VAR}_TWEAK "${_TMP}" PARENT_SCOPE)
		else()
			unset(${OUT_VAR}_TWEAK PARENT_SCOPE)
		endif()
		# {5} = PreRelease
		if(CMAKE_MATCH_5)
			string(SUBSTRING "${CMAKE_MATCH_5}" 0 1 _TMP)
			if(_TMP STREQUAL "-")
				string(SUBSTRING "${CMAKE_MATCH_5}" 1 -1 _TMP)
				set(${OUT_VAR}_PRERELEASE "${_TMP}" PARENT_SCOPE)
			else()
				set(${OUT_VAR}_PRERELEASE "${CMAKE_MATCH_5}" PARENT_SCOPE)
			endif()
		else()
			unset(${OUT_VAR}_PRERELEASE PARENT_SCOPE)
		endif()
		# {6} = Build
		if(CMAKE_MATCH_6)
			string(SUBSTRING "${CMAKE_MATCH_6}" 1 -1 _TMP)
			set(${OUT_VAR}_BUILD "${_TMP}" PARENT_SCOPE)
		else()
			unset(${OUT_VAR}_BUILD PARENT_SCOPE)
		endif()
	elseif(ARGV0 STREQUAL "GENERATE")
		cmake_parse_arguments(
			PARSE_ARGV 2
			_ARGS
			"COMPRESS"
			"MAJOR;MINOR;PATCH;TWEAK;PRERELEASE;BUILD"
			""
		)

		# Do we have the major component, and is it valid?
		if(DEFINED _ARGS_MAJOR)
			string(STRIP "${_ARGS_MAJOR}" _ARGS_MAJOR)
			if(_ARGS_MAJOR STREQUAL "")
				set(_ARGS_MAJOR 0)
			elseif(NOT (_ARGS_MAJOR MATCHES [[^[0-9]+$]]))
				set(${OUT_VAR}_ERROR "MAJOR component must be a numeric identifier, but is: '${_ARGS_MAJOR}'" PARENT_SCOPE)
				return()
			endif()
		else()
			set(_ARGS_MAJOR 0)
		endif()
		set(_ "${_}${_ARGS_MAJOR}")

		# Do we have the minor component, and is it valid?
		if(DEFINED _ARGS_MINOR)
			string(STRIP "${_ARGS_MINOR}" _ARGS_MINOR)
			if(_ARGS_MINOR STREQUAL "")
				set(_ARGS_MINOR 0)
			elseif(NOT (_ARGS_MINOR MATCHES [[^[0-9]+$]]))
				set(${OUT_VAR}_ERROR "MINOR component must be a numeric identifier, but is: '${_ARGS_MINOR}'" PARENT_SCOPE)
				return()
			endif()
		else()
			set(_ARGS_MINOR 0)
		endif()
		set(_ "${_}.${_ARGS_MINOR}")

		# Do we have the patch component, and is it valid?
		if(DEFINED _ARGS_PATCH)
			string(STRIP "${_ARGS_PATCH}" _ARGS_PATCH)
			if(_ARGS_PATCH STREQUAL "")
				unset(_ARGS_PATCH)
			elseif(_ARGS_PATCH MATCHES [[^[0-9]+$]])
				set(_ "${_}.${_ARGS_PATCH}")
			else()
				set(${OUT_VAR}_ERROR "PATCH component must be a numeric identifier, but is: '${_ARGS_PATCH}'" PARENT_SCOPE)
				return()
			endif()
		endif()

		# Do we have the tweak component, and is it valid?
		if(DEFINED _ARGS_TWEAK)
			string(STRIP "${_ARGS_TWEAK}" _ARGS_TWEAK)
			if(_ARGS_TWEAK STREQUAL "")
				unset(_ARGS_TWEAK)
			elseif(_ARGS_TWEAK MATCHES [[^[0-9]+$]])
				if(NOT DEFINED _ARGS_PATCH)
					set(_ "${_}.0")
				endif()
				set(_ "${_}.${_ARGS_TWEAK}")
			else()
				set(${OUT_VAR}_ERROR "TWEAK component must be a numeric identifier, but is: '${_ARGS_TWEAK}'" PARENT_SCOPE)
				return()
			endif()
		endif()

		# Do we have the pre-release component, and is it valid?
		if(DEFINED _ARGS_PRERELEASE)
			string(STRIP "${_ARGS_PRERELEASE}" _ARGS_PRERELEASE)
			if(_ARGS_PRERELEASE STREQUAL "")
				unset(_ARGS_PRERELEASE)
			elseif(_ARGS_PRERELEASE MATCHES [[^[a-zA-Z0-9]+[a-zA-Z0-9\-\.]*$]])
				if(_ARGS_COMPRESS AND (_ARGS_PRERELEASE MATCHES [[[a-zA-Z]+[a-zA-Z0-9\\-\\.]*$]]))
					set(_ "${_}${_ARGS_PRERELEASE}")
				else()
					set(_ "${_}-${_ARGS_PRERELEASE}")
				endif()
			else()
				set(${OUT_VAR}_ERROR "PRERELEASE component must be an alphanumeric identifier, but is: '${_ARGS_PRERELEASE}'" PARENT_SCOPE)
				return()
			endif()
		endif()

		# Do we have the build component, and is it valid?
		if(DEFINED _ARGS_BUILD)
			string(STRIP "${_ARGS_BUILD}" _ARGS_PRERELEASE)
			if(_ARGS_BUILD STREQUAL "")
				unset(_ARGS_BUILD)
			elseif(_ARGS_BUILD MATCHES [[^[a-zA-Z0-9]+[a-zA-Z0-9\-\.]*$]])
				set(_ "${_}+${_ARGS_BUILD}")
			else()
				set(${OUT_VAR}_ERROR "BUILD component must be an alphanumeric identifier, but is: '${_ARGS_BUILD}'" PARENT_SCOPE)
				return()
			endif()
		endif()

		set(${OUT_VAR} "${_}" PARENT_SCOPE)
	elseif(ARGV0 STREQUAL "MODIFY")
		# Requires PARSE and GENERATE.
		cmake_parse_arguments(
			PARSE_ARGV 3
			_ARGS
			"COMPRESS"
			"MAJOR;MINOR;PATCH;BUILD;PRERELEASE;COMMIT"
			""
		)

		# Helpers
		macro(modify_version_number)
			if(DEFINED ${ARGV1})
				if(${ARGV1} MATCHES "^(\\+|\\-)([0-9]+)$")
					if(DEFINED ${ARGV0})
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
		version(PARSE _TEMP "${ARGV2}")
		if(DEFINED _TEMP_ERROR)
			set(${OUT_VAR}_ERROR ${_TEMP_ERROR} PARENT_SCOPE)
			return()
		endif()

		# Modify core version components
		modify_version_number(_TEMP_MAJOR _ARGS_MAJOR)
		modify_version_number(_TEMP_MINOR _ARGS_MINOR)
		modify_version_number(_TEMP_PATCH _ARGS_PATCH)
		modify_version_number(_TEMP_TWEAK _ARGS_TWEAK)

		# Replace other components if defined.
		if(DEFINED _ARGS_PRERELEASE)
			set(_TEMP_PRERELEASE "${_ARGS_PRERELEASE}")
		endif()
		if(DEFINED _ARGS_BUILD)
			set(_TEMP_BUILD "${_ARGS_BUILD}")
		endif()

		# Generate a new version.
		set(_ARGS "")
		if(DEFINED _TEMP_MAJOR AND (NOT _TEMP_MAJOR STREQUAL ""))
			set(_ARGS "${_ARGS} MAJOR \"${_TEMP_MAJOR}\"")
		endif()
		if(DEFINED _TEMP_MINOR AND (NOT _TEMP_MINOR STREQUAL ""))
			set(_ARGS "${_ARGS} MINOR \"${_TEMP_MINOR}\"")
		endif()
		if(DEFINED _TEMP_PATCH AND (NOT _TEMP_PATCH STREQUAL ""))
			set(_ARGS "${_ARGS} PATCH \"${_TEMP_PATCH}\"")
		endif()
		if(DEFINED _TEMP_TWEAK AND (NOT _TEMP_TWEAK STREQUAL ""))
			set(_ARGS "${_ARGS} TWEAK \"${_TEMP_TWEAK}\"")
		endif()
		if(DEFINED _TEMP_PRERELEASE AND (NOT _TEMP_PRERELEASE STREQUAL ""))
			set(_ARGS "${_ARGS} PRERELEASE \"${_TEMP_PRERELEASE}\"")
		endif()
		if(DEFINED _TEMP_BUILD AND (NOT _TEMP_BUILD STREQUAL ""))
			set(_ARGS "${_ARGS} BUILD \"${_TEMP_BUILD}\"")
		endif()
		if(DEFINED _ARGS_COMPRESS)
			set(_ARGS "${_ARGS} COMPRESS")
		endif()
		cmake_language(EVAL CODE "version(GENERATE _TEMP ${_ARGS})")
		if(DEFINED _TEMP_ERROR)
			set(${OUT_VAR}_ERROR ${_TEMP_ERROR} PARENT_SCOPE)
			return()
		endif()
		set(${OUT_VAR} "${_TEMP}" PARENT_SCOPE)
	elseif(ARGV0 STREQUAL "COMPARE")
		# Requires PARSE.

		# Parse first version
		version(PARSE _A "${ARGV2}")
		if(DEFINED _A_ERROR)
			set(${OUT_VAR}_ERROR ${_A_ERROR} PARENT_SCOPE)
			return()
		endif()

		# Parse second version
		version(PARSE _B "${ARGV3}")
		if(DEFINED _B_ERROR)
			set(${OUT_VAR}_ERROR ${_B_ERROR} PARENT_SCOPE)
			return()
		endif()

		# Major
		if(_A_MAJOR GREATER _B_MAJOR)
			set(${OUT_VAR} ">MAJOR" PARENT_SCOPE)
			return()
		elseif(_A_MAJOR LESS _B_MAJOR)
			set(${OUT_VAR} "<MAJOR" PARENT_SCOPE)
			return()
		endif()

		# Minor
		if(_A_MINOR GREATER _B_MINOR)
			set(${OUT_VAR} ">MINOR" PARENT_SCOPE)
			return()
		elseif(_A_MINOR LESS _B_MINOR)
			set(${OUT_VAR} "<MINOR" PARENT_SCOPE)
			return()
		endif()

		# Patch
		if((DEFINED _A_PATCH OR DEFINED _B_PATCH) AND ((NOT DEFINED _A_PATCH) OR (NOT DEFINED _B_PATCH)))
			if(DEFINED _A_PATCH)
				set(${OUT_VAR} "+PATCH" PARENT_SCOPE)
			else()
				set(${OUT_VAR} "-PATCH" PARENT_SCOPE)
			endif()
			return()
		elseif(_A_PATCH GREATER _B_PATCH)
			set(${OUT_VAR} ">PATCH" PARENT_SCOPE)
			return()
		elseif(_A_PATCH LESS _B_PATCH)
			set(${OUT_VAR} "<PATCH" PARENT_SCOPE)
			return()
		endif()

		# Tweak
		if((DEFINED _A_TWEAK OR DEFINED _B_TWEAK) AND ((NOT DEFINED _A_TWEAK) OR (NOT DEFINED _B_TWEAK)))
			if(DEFINED _A_TWEAK)
				set(${OUT_VAR} "+TWEAK" PARENT_SCOPE)
			else()
				set(${OUT_VAR} "-TWEAK" PARENT_SCOPE)
			endif()
			return()
		elseif(_A_TWEAK GREATER _B_TWEAK)
			set(${OUT_VAR} ">TWEAK" PARENT_SCOPE)
			return()
		elseif(_A_TWEAK LESS _B_TWEAK)
			set(${OUT_VAR} "<TWEAK" PARENT_SCOPE)
			return()
		endif()

		# Pre-Release
		if((DEFINED _A_PRERELEASE) AND (DEFINED _B_PRERELEASE) AND (NOT (_A_PRERELEASE STREQUAL _B_PRERELEASE)))
			set(${OUT_VAR} "PRERELEASE" PARENT_SCOPE)
			return()
		elseif((DEFINED _A_PRERELEASE OR DEFINED _B_PRERELEASE) AND ((NOT DEFINED _A_PRERELEASE) OR (NOT DEFINED _B_PRERELEASE)))
			if(DEFINED _A_PRERELEASE)
				set(${OUT_VAR} "+PRERELEASE" PARENT_SCOPE)
			else()
				set(${OUT_VAR} "-PRERELEASE" PARENT_SCOPE)
			endif()
			return()
		endif()

		# Build
		if((DEFINED _A_BUILD) AND (DEFINED _B_BUILD) AND (NOT (_A_BUILD STREQUAL _B_BUILD)))
			set(${OUT_VAR} "BUILD" PARENT_SCOPE)
			return()
		elseif((DEFINED _A_BUILD OR DEFINED _B_BUILD) AND ((NOT DEFINED _A_BUILD) OR (NOT DEFINED _B_BUILD)))
			if(DEFINED _A_BUILD)
				set(${OUT_VAR} "+BUILD" PARENT_SCOPE)
			else()
				set(${OUT_VAR} "-BUILD" PARENT_SCOPE)
			endif()
			return()
		endif()

		# Both are exactly the same.
		set(${OUT_VAR} "" PARENT_SCOPE)
	else()
		message(FATAL_ERROR "Unknown command '${ARGV0}'")
		return()
	endif()
endfunction()