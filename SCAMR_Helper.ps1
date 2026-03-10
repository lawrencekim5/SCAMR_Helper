# Reinitializing variables. Weird things happen if I don't do this.
$sourceFolder = ""
$API_URL = ""

# Prompts user to enter in the file path or URL containing their source code. Removes "/" and "\" that is sometimes included when copying pasting URLs
$sourceFolder = Read-Host "Enter the file path or URL of the root directory of your source code. Only GitHub and GitLab links are supported"
$sourceFolder = $sourceFolder -replace '/$', '' -replace '\$', ''
# https://github.com/lawrencekim5/SCAMR_Helper_SampleSourceCode
# https://api.github.com/repos/lawrencekim5/SCAMR_Helper_SampleSourceCode/contents



##############################################################################
# This part of the code handles remote source code locations (GitHub/GitLab) #
##############################################################################

# GitHub and GitLab use https so this is the easiest way to detect a URL

 
# Detecting URLs is easiest by matching https in input   
if ($sourceFolder -Match 'https://') {


    ##########
    # Handling GitHub Use Cases
    ##########
    if ($sourceFolder -Match "https://github") {
        $type = 'github'
        
        # Regex to remove a portion of the URL to retain only the path of the directory
        $sourcePath = $sourceFolder -replace '^.*\.com/', ''  -replace '/$',''

        # sourcePath example: /lawrencekim5/SCAMR_Helper_SampleSourceCode

        $API_URL = "https://api.github.com/repos/" + $sourcePath + "/contents"
    }
    
    ##########    
    # Handling GitLab Use Cases
    ##########

    elseif ($sourceFolder -Match "https://gitlab") {
        $type = 'gitlab'

        # https://gitlab.com/lawrencekim5-group/SCAMR_Helper_SampleSourceCode
        # https://gitlab.com/api/v4/projects/lawrencekim5-group%2fSCAMR_Helper_SampleSourceCode/repository/tree
    

        # obtains the source path of the project by stripping away the beginning part of the URL
        $sourcePath = $sourceFolder -replace '^.*\.com/', ''  -replace '/$',''

        # URL encoding the source path so that it can be properly used with the GitLab API
        $URLencodedSourcePath = [System.Web.HttpUtility]::UrlEncode($sourcePath)

        # Get user's GitLab API Token
        $token = Read-Host "Enter your GitLab API Token"
        
        # Authorize GitLab access through token in header
        # FIXME - add some way to take this in as a secure string
        $headers = @{          
            "PRIVATE-TOKEN" = "$token"
        }

        # Format the GitLab URL using the URL encoded path
        $DirectoryListURL = 'https://gitlab.com/api/v4/projects/' + "$URLencodedSourcePath" + '/repository/tree'
        
    }


    # Exit on invalid input
    else {
        Read-Host "Not a valid GitHub or GitLab link. Exiting script. Press any key to exit"
        exit
    }

    
    ##########
    # This section of code is intended to allow the user to view the contents of their source code directory to verify their URL input
    ##########


    # Call the GitHub/GitLab API to get information about the root directory
    try {

        # Call GitHub API
        if ($type -eq 'github') {
            $remoteFileList = Invoke-RestMethod $API_URL -UseBasicParsing -ErrorAction Stop
        }
        
        # Call GitLab API
        else {
            $remoteFileList = Invoke-RestMethod -Headers $headers -Uri $DirectoryListURL -UseBasicParsing -ErrorAction Stop
        }
    }

    # Notifies the user that the URL was inaccessible
    catch {
        ""
        "ERROR MESSAGE: $($Error[0])"
        ""
        Write-Host "UNABLE TO DISPLAY DIRECTORY INFORMATION"
        $confirmation = Read-Host "An Error occured when attempting to access the URL. Do you wish to continue regardless? [y/n]"
        if ($confirmation -eq 'y') {
                Write-Host "Continuing script..."
            }

            # Exit code if [y] is not the input
            elseif ($confirmation -eq 'n') {
                Read-Host "Exiting script. Please rerun the script to try again. Press any key to exit"
                exit
            }

            else {
                Read-Host "Invalid input. Exiting script. Press any key to exit"
                exit
            }
    }


    # Creates an array to store root directory information
    $remoteFileListArray = @()
    $remoteFileListArray = $remoteFileList -split ' '


    # Displays the names of files and directories in the root directory. Also formats the output to be cleaner.
    ""
    Write-Host "Files found in directory:"

    # Formatting GitHub API Output
    if ($type -eq 'github') {
        $remoteFileListArray | Where-Object {$_ -like '*name*'} | ForEach-Object {$_.Substring(7)}
    }

    # Formatting GitLab API Output
    else {
        $remoteFileListArray | Where-Object {$_ -like '*name*'} | ForEach-Object {$_.Substring(5)}
    }
    # [y/n] Confirmation Prompt
    ""
    $confirmation = Read-Host "Does this look correct? [y/n]"

        # Proceed if [y] is the input
        if ($confirmation -eq 'y') {
            Write-Host "Confirmed"

            ##########
            # Handing GitHub Hyperlink creation
            ##########

            if ($type -eq 'github') {
                # Add way to get hyperlink for GitHub
                # https://github.com/lawrencekim5/SCAMR_Helper_SampleSourceCode/blob/main/Objects/clinic/listobject.c.h#L8
                $hyperlink_base = "$sourceFolder" + '/blob/main/'
                Write-Host "Hyperlink format is $hyperlink_base{path}"
                
            }

            ##########
            # Handling GitLab Hyperlink Creation
            ##########

            else {
                # https://gitlab.com/lawrencekim5-group/SCAMR_Helper_SampleSourceCode/-/blob/main/Include/audit.h?ref_type=heads
                $hyperlink_base = "$sourceFolder" + '/-/blob/main/'
                Write-Host "Hyperlink format is $hyperlink_base{path}"
                
            }


        }

        # Exit code if [y] is not the input
        elseif ($confirmation -eq 'n') {
            Read-Host "Exiting script. Please rerun the script to try again. Press any key to exit"
            exit
        }

        else {
            Read-Host "Invalid input. Exiting script. Press any key to exit"
            exit
        }
            
    
}



######################################################################################
# This part of the code handles local source code locations (integrates with VSCode) #
######################################################################################

else {
    $type = 'local'
    $sourcePath = $sourceFolder
    try {

        # Lists files in the path of the source folder
        Get-ChildItem -Path "$sourceFolder" -ErrorAction Stop
        ""

        # [y/n] Confirmation Prompt
        $confirmation = Read-Host "Does this look correct? [y/n]"


            # Proceed if [y] is the input
            if ($confirmation -eq 'y') {
                Write-Host "Confirmed"
            }

            # Exit code if [y] is not the input
            elseif ($confirmation -eq 'n') {
                Read-Host "Exiting script. Please rerun the script to try again. Press any key to exit"
                exit
            }

            else {
                Read-Host "Invalid input. Exiting script. Press any key to exit"
                exit
            }
    }


    # Error Catching for invalid file paths
    catch {
        ""
        "ERROR MESSAGE: $($Error[0])"
        ""
        Write-Host "UNABLE TO DISPLAY DIRECTORY INFORMATION"
        $confirmation = Read-Host "Unable to find the path on your local machine. Do you wish to continue regardless? [y/n]"
        if ($confirmation -eq 'y') {
                Write-Host "Continuing script..."
            }

            # Exit code if [y] is not the input
            elseif ($confirmation -eq 'n') {
                Read-Host "Exiting script. Please rerun the script to try again. Press any key to exit"
                exit
            }

            else {
                Read-Host "Invalid input. Exiting script. Press any key to exit"
                exit
            }
    }
}



################################
# CSV Parsing and Modification #
################################

Write-Host "Select the CSV file to be modified."

# FileDialog code gotten from here: https://devblogs.microsoft.com/scripting/hey-scripting-guy-can-i-open-a-file-dialog-box-with-windows-powershell/
# Prompts user to select the CSV file that is to be modified by SCAMR Helper
Function Get-CSVPath($initialDirectory) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

try {
    $CSVfilepath = Get-CSVPath
    $rawCSVdata = Import-CSV -Path $CSVfilepath
}

# Error handling for improper CSV files
catch {
    Write-Host "An error occured. Please check whether the input CSV file is valid. Exiting script. Press any key to exit"
    exit
}


# **Just some test code to get the file headers from the CSV file**
# $columns = ($rawCSVdata | Get-Member -MemberType NoteProperty).Name
# Write-Host $columns

###############
# This section of code extracts the name of the column header that is used for filepaths in the CSV.
###############
# Creates an array storing the values underneath each column header. This is surprisingly robust as long as if the filepath does not contain semicolons
$CSVdatafields = $rawCSVdata[0] -split ";"

# converting sourcePath to the minimum necessary for identification for compatibility
if ($type -ne 'local') {
    $sourcePath = $sourcePath -replace '.*/', '' -replace '/$',''
}

# Loops through the array and identifies matches with the $sourcePath variable. This allows for the column header for filenames
# to be retrieved without any hardcoding.
foreach ($item in $CSVdatafields) {
  
    if ($item.Contains("$sourcePath")) {
        # Regex to remove the equals sign and everything afterwards, and white spaces. This leaves just the column header name
        $filenameHeader = $item -replace '=.*$', '' -replace '\s+', ''
    }
}

# Error handing incase source path can not be identified in the CSV file
if ($filenameHeader -eq '') {
    Write-Host "Source code path was unable to be identified in the CSV file. Please check the file and make sure that it matches your source code repository location."
    Read-Host "Exiting script. Press any key to exit"
    exit
}

Write-Host $filenameHeader




foreach ($item in $rawCSVdata) {
    
    # extract relevant filepath and filename, extract line number, add columns to include hyperlink quick access to code, hyperlink quick access to cwe, and then hyperlink helper columns
    

    # Some variables to track the values of the current item. Just makes the script more readable.
    $item_filename = $($item.$filenameHeader)
    $item_line = $($item.line)
    $item_cwe = $($item.cwe)

    # Displays loop progress so that users don't think the script is hanging
    $loopCounter = $rawCSVdata.IndexOf($item) + 1
    Write-Host "$loopCounter item(s) identified!"
    Write-Host "File name:   $item_filename"
    Write-Host "Line number: $item_line"
    Write-Host "CWE:         $item_cwe"
    ""
        
    ###############################################
    # Hyperlink creation based on repository type #
    ###############################################


    if ($item_filename -ne '') {

        # Local Hyperlinks
        if ($type -eq 'local') {
            $hyperlink_notClickable = "vscode://file/" + $item_filename + ":" + $item_line
            $hyperlink_filename = $hyperlink_notClickable -replace '.*\\', ''
            $hyperlink_clickable = "=HYPERLINK(`"" + $hyperlink_notClickable + "`", `"" + $hyperlink_filename + "`")"
        }


        # GitHub Hyperlinks
        elseif ($type -eq 'github') {
            $hyperlink_minusSourcePath = $item_filename -replace ".*$sourcePath", '' -replace '^/', ''
            $hyperlink_notClickable = $hyperlink_base + $hyperlink_minusSourcePath + "#L" + $item_line
            $hyperlink_filename = $hyperlink_notClickable -replace '.*\/', ''
            $hyperlink_clickable = "=HYPERLINK(`"" + $hyperlink_notClickable + "`", `"" + $hyperlink_filename + "`")"
        }


        # GitLab Hyperlinks
        elseif ($type -eq 'gitlab') {
            $hyperlink_minusSourcePath = $item_filename -replace ".*$sourcePath", '' -replace '^/', ''
            $hyperlink_notClickable = $hyperlink_base + $hyperlink_minusSourcePath + "#L" + $item_line
            $hyperlink_filename = $hyperlink_notClickable -replace '.*\/', ''
            $hyperlink_clickable = "=HYPERLINK(`"" + $hyperlink_notClickable + "`", `"" + $hyperlink_filename + "`")"
        }

        else {
            exit
        }
        

        # Hyperlinking to MITRE CWEs


    }

    # Stop looping once filename doesn't exist in item
    else {
        break
    }




    ##############################################################################
    # This section of the code adds the hyperlinks to the columns of the CSV file#
    ##############################################################################
    
    # CSV Modification code

    # Appends a column with the hyperlink to each object in the $rawCSVdata array
    $item | Add-Member -MemberType NoteProperty -Name "Link to Finding" -Value "$hyperlink_clickable"
    
    # Creates MITRE hyperlink based off of the CWE identifier
    $MITRE_hyperlink = "=HYPERLINK(`"https://cwe.mitre.org/data/definitions/" + $item_cwe + ".html`"" + ", `"CWE: " + $item_cwe + "`")"

    # Appends a column with the hyperlink to the MITRE CWE site for each object in the $rawCSVdata array if an associated CWE exists
    if ($item_cwe -ne '') {
        $item | Add-Member -MemberType NoteProperty -Name "Link to MITRE CWE" -Value "$MITRE_hyperlink"
    }
    
    
}

# While iterates stays until an acceptable file name is given. This ensures that the file is saved with a valid name.
$fileSaveSuccess = 'False'
while ($fileSaveSuccess -eq 'False') {
    # Removes ".csv" extension if it is already provided, adds .csv extension afterwards
    $ModifiedCSVfilename = Read-Host "Enter a name to save the modifed CSV file as"
    $ModifiedCSVfilename = $ModifiedCSVfilename -replace '\.csv$',''
    $ModifiedCSVfilename += '.csv'
    try {
        $rawCSVdata | Export-CSV "$ModifiedCSVfilename" -NoTypeInformation
        $fileSaveSuccess = 'True'
        break
    }
    catch {
        ""
        "ERROR MESSAGE: $($Error[0])"
        ""
        Write-Host "An error occured when attempting to save the file name. Please check and try again."
    }
}


Read-Host "Modifications complete! File saved as $ModifiedCSVfilename. Press any key to exit"


