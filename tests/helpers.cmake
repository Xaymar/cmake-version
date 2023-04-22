include("../version.cmake")

function(compare_test)
	cmake_parse_arguments(
		PARSE_ARGV 1
		_6edc8bbd
		"FAIL"
		""
		""
	)
	if(_TEST_ERROR)
		if(_6edc8bbd_FAIL)
			message(STATUS "PASSED: '${ARGV0}'.\n\t${_TEST_ERROR}")
		else()
			message(SEND_ERROR "FAILED: '${ARGV0}'.\n\t${_TEST_ERROR}")
		endif()
	else()
		if((ARGV0 STREQUAL _TEST) AND (NOT _6edc8bbd_FAIL))
			message(STATUS "PASSED: '${ARGV0}'.")
		else()
			message(SEND_ERROR "FAILED: '${ARGV0}' != '${_TEST}'.")
		endif()
	endif()
endfunction()

function(test_parse)
	cmake_parse_arguments(
		PARSE_ARGV 1
		_6edc8bbd
		"FAIL"
		"MAJOR;MINOR;PATCH;TWEAK;PRERELEASE;BUILD"
		""
	)
	version(PARSE _TEST "${ARGV0}")

	set(FAILED OFF)
	set(MESSAGE "${_TEST_ERROR}")
	if(NOT _TEST_ERROR)
		if(_6edc8bbd_MAJOR)
			if(NOT _TEST_MAJOR)
				set(MESSAGE "MAJOR component missing during parse.")
				set(FAILED ON)
			elseif(NOT (_TEST_MAJOR STREQUAL _6edc8bbd_MAJOR))
				set(MESSAGE "MAJOR component mismatch: '${_TEST_MAJOR}' != '${_6edc8bbd_MAJOR}'")
				set(FAILED ON)
			endif()
		endif()
		
		if(_6edc8bbd_MINOR)
			if(NOT _TEST_MINOR)
				set(MESSAGE "MINOR component missing during parse.")
				set(FAILED ON)
			elseif(NOT (_TEST_MINOR STREQUAL _6edc8bbd_MINOR))
				set(MESSAGE "MINOR component mismatch: '${_TEST_MINOR}' != '${_6edc8bbd_MINOR}'")
				set(FAILED ON)
			endif()
		endif()
		
		if(_6edc8bbd_PATCH)
			if(NOT _TEST_PATCH)
				set(MESSAGE "PATCH component missing during parse.")
				set(FAILED ON)
			elseif(NOT (_TEST_PATCH STREQUAL _6edc8bbd_PATCH))
				set(MESSAGE "PATCH component mismatch: '${_TEST_PATCH}' != '${_6edc8bbd_PATCH}'")
				set(FAILED ON)
			endif()
		endif()
		
		if(_6edc8bbd_TWEAK)
			if(NOT _TEST_TWEAK)
				set(MESSAGE "TWEAK component missing during parse.")
				set(FAILED ON)
			elseif(NOT (_TEST_TWEAK STREQUAL _6edc8bbd_TWEAK))
				set(MESSAGE "TWEAK component mismatch: '${_TEST_TWEAK}' != '${_6edc8bbd_TWEAK}'")
				set(FAILED ON)
			endif()
		endif()
		
		if(_6edc8bbd_PRERELEASE)
			if(NOT _TEST_PRERELEASE)
				set(MESSAGE "PRERELEASE component missing during parse.")
				set(FAILED ON)
			elseif(NOT (_TEST_PRERELEASE STREQUAL _6edc8bbd_PRERELEASE))
				set(MESSAGE "PRERELEASE component mismatch: '${_TEST_PRERELEASE}' != '${_6edc8bbd_PRERELEASE}'")
				set(FAILED ON)
			endif()
		endif()
		
		if(_6edc8bbd_BUILD)
			if(NOT _TEST_BUILD)
				set(MESSAGE "BUILD component missing during parse.")
				set(FAILED ON)
			elseif(NOT (_TEST_BUILD STREQUAL _6edc8bbd_BUILD))
				set(MESSAGE "BUILD component mismatch: '${_TEST_BUILD}' != '${_6edc8bbd_BUILD}'")
				set(FAILED ON)
			endif()
		endif()
	else()
		set(FAILED ON)
	endif()

	if(FAILED)
		if(_6edc8bbd_FAIL)
			message(STATUS "PASSED: '${ARGV0}'.\n\t${MESSAGE}")
		else()
			message(SEND_ERROR "FAILED: '${ARGV0}'.\n\t${MESSAGE}")
		endif()
	else()
		if(_6edc8bbd_FAIL)
			message(SEND_ERROR "FAILED: '${ARGV0}'.")
		else()
			message(STATUS "PASSED: '${ARGV0}'.")
		endif()
	endif()
endfunction()

function(test_compare)
	cmake_parse_arguments(
		PARSE_ARGV 3
		_6edc8bbd
		"FAIL"
		"RESULT"
		""
	)

	version(COMPARE _TEST "${ARGV0}" "${ARGV2}")
	set(FAILED OFF)
	if(_TEST_ERROR)
		set(MESSAGE "${_TEST_ERROR}")
		set(FAILED ON)
	else()
		if(NOT (_TEST STREQUAL ARGV1))
			set(MESSAGE "'${_TEST}' != '${ARGV1}'")
			set(FAILED ON)
		endif()
	endif()

	if(FAILED)
		if(_6edc8bbd_FAIL)
			message(STATUS "PASSED: '${ARGV0}' '${ARGV1}' '${ARGV2}'.\n\t${MESSAGE}")
		else()
			message(SEND_ERROR "FAILED: '${ARGV0}' '${ARGV1}' '${ARGV2}'.\n\t${MESSAGE}")
		endif()
	else()
		if(_6edc8bbd_FAIL)
			message(SEND_ERROR "FAILED: '${ARGV0}' '${ARGV1}' '${ARGV2}'.\n\t${MESSAGE}")
		else()
			message(STATUS "PASSED: '${ARGV0}' '${ARGV1}' '${ARGV2}'.")
		endif()
	endif()
endfunction()