function uae4arm::report()
{
        echo "System: ${1}" >&2
        echo "Emulator: ${2}" >&2
        echo "ROM: ${3}" >&2
        echo "Command: ${4}" >&2
}

function uae4arm::prerequisitecheck()
{
	command -v unzip >/dev/null 2>&1
	if [[ $? -gt 0 ]]; then
		echo "unzip command not installed"
		return 1
	fi

	command -v zip >/dev/null 2>&1
	if [[ $? -gt 0 ]]; then
		echo "zip command not installed"
		return 1
	fi
}

function uae4arm::parseconfig()
{
	local uae_config="${1}"	
	if [[ -e "${uae_config}" ]]; then
		uae_hdd_path=$( grep -E "^uaehf0=dir,rw,DH1:games:" "${uae_config}" )

		if [[ $? -gt 0 ]]; then
			echo "uaehf0 not specified in UAE config" >&2
			echo "Regex used: ^uaehf0=dir,rw,DH1:games:" >&2
			return 1
		fi

		uae_hdd_path=${uae_hdd_path#*uaehf0=dir,rw,DH1:games:}
		uae_hdd_path=${uae_hdd_path%/,0}

		if ! [[ "$uae_hdd_path" == /* ]]; then
			echo "'${uae_hdd_path}' does not look like a valid path!"
			return 1
		fi
		
		uae_zip_path="${uae_hdd_path}.zip"
		uae_game_name=$( basename ${uae_hdd_path} )
		uae_whdload_folder=$( dirname ${uae_hdd_path} )
		uae_zip_destination="/dev/shm/whdload_temp/${uae_game_name}"

		echo "UAE HDD Path: ${uae_hdd_path}" >&2
		echo "UAE Game Name: ${uae_game_name}" >&2
		echo "UAE HDD ZIP: ${uae_zip_path}" >&2
		echo "UAE WhdLoad Folder: ${uae_whdload_folder}" >&2
		echo "UAE WhdLoad Temp Folder: ${uae_zip_destination}" >&2
	else
		echo "Could not find UAE config file ${uae_config}" >&2
		return 1
	fi
	return 0
}

function uae4arm::testhddpath()
{
	if [[ -d "${uae_hdd_path}" ]]; then
		echo "UAE HDD already in place, nothing to do" >&2
		return 1
	fi
	broken_symlink=$( find -L "${uae_hdd_path}" -type l )
	if [[ -z "${broken_symlink}" ]]; then
		return 0
	else
		# Cleanup broken symlink
		find -L "${uae_whdload_folder}" -type l -exec rm {} +
	fi
	return 0
}

function uae4arm::setupgame()
{
	if [[ -e "${uae_zip_path}" ]]; then
		mkdir -p $( dirname "${uae_zip_destination}" )
		unzip -u "${uae_zip_path}" -d "${uae_zip_destination}" >&2
		if [[ $? -gt 0 ]]; then
			echo "Failed to unzip '${uae_zip_path}' to '${uae_zip_destination}'" >&2
			return 1
		fi

		# Create symlink
		ln -s "${uae_zip_destination}" "${uae_hdd_path}"
		if [[ $? -gt 0 ]]; then
			echo "Failed to create symlink from '${uae_zip_destination}' to '${uae_hdd_path}'" >&2
			return 1
		fi
	else
		echo "'${uae_zip_path}' does not exist" >&2
		return 1
	fi

	return 0
}

function uae4arm::cleanupgame()
{
	if  [[ "${uae_zip_destination}" -ef "${uae_hdd_path}" && -L ${uae_hdd_path} ]]; then
		# Only zip changed files
		pushd "${uae_zip_destination}"
		echo "Updating Zip with changes: '${uae_zip_path}'" >&2
		zip "${uae_zip_path}" -r -u * >&2
		popd

		# Remove symlink 
		echo "Removing symlink file: '${uae_hdd_path}'" >&2
		rm ${uae_hdd_path} >&2
		if [[ $? > 0 ]]; then
			return 1
		fi

		# Remove temp folder
		echo "Removing WhdLoad temp folder: '${uae_zip_destination}'" >&2
		rm -r "${uae_zip_destination}" >&2
		if [[ $? > 0 ]]; then
			return 1
		fi
	fi
	return 0
}

function uae4arm::preplaunch()
{
        # Echo out launch parameters
		uae4arm::report "${1}" "${2}" "${3}" "${4}"
		
		# Check zip and unzip commands installed before proceeding
		uae4arm::prerequisitecheck
		if [[ $? -gt 0 ]]; then
			return 1
		fi

		# Setup variables required for script
		uae4arm::parseconfig "${3}"
		if [[ $? -gt 0 ]]; then
			return 1
		fi
		
		# Check to see if HDD folder already exists
		uae4arm::testhddpath
		if [[ $? -gt 0 ]]; then
			return 0
		fi

		# Setup the game
		uae4arm::setupgame
		if [[ $? -gt 0 ]]; then
			return 1
		fi

		return 0
}

function uae4arm::cleanexit()
{
        # Echo out launch parameters
		uae4arm::report "${1}" "${2}" "${3}" "${4}"
		
		# Check zip and unzip commands installed before proceeding
		uae4arm::prerequisitecheck
		if [[ $? -gt 0 ]]; then
			return 1
		fi

		# Setup variables required for script
		uae4arm::parseconfig "${3}"
		if [[ $? -gt 0 ]]; then
			return 1
		fi

		# Rezip WhdLoad package and Cleanup temporary files
		uae4arm::cleanupgame
		if [[ $? -gt 0 ]]; then
			return 1
		fi

		return 0
}

if [[ "${2}" == "uae4arm" ]] && [[ "${5}" == "start" ]]; then
	uae4arm::preplaunch "${1}" "${2}" "${3}" "${4}"
fi

if [[ "${2}" == "uae4arm" ]] && [[ "${5}" == "stop" ]]; then
	uae4arm::cleanexit "${1}" "${2}" "${3}" "${4}"
fi