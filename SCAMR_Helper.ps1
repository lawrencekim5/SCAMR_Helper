# Reinitializing variables. Weird things happen if I don't do this.
$sourceFolder = ""
$API_URL = ""

$sourceFolder = Read-Host "Enter the file path or URL of the root directory of your source code. Only GitHub and GitLab links are supported"
# https://github.com/lawrencekim5/SCAMR_Helper_SampleSourceCode
# https://api.github.com/repos/lawrencekim5/SCAMR_Helper_SampleSourceCode/contents



#############################################################################
# This part of the code handles remote source code locations (GitHub/GitLab)#
#############################################################################

# GitHub and GitLab use https so this is the easiest way to detect a URL
if ($sourceFolder -Match "https://") {
 
    ##########
    # Handling GitHub Use Cases
    ##########

    if ($sourceFolder -Match "https://github") {
        $type = 'github'
        
        # Regex to remove a portion of the URL to retain only the path of the directory
        $API_URL = $sourceFolder -replace '^.*\.com', ''
        $API_URL = "https://api.github.com/repos" + $API_URL + "/contents"
        }
    
    ##########    
    # Handling GitLab Use Cases
    ##########


    # Example code for using the API in PowerShell to perform requests.
#   elseif ($sourceFolder -Match "https://gitlab") {
#       $type = 'gitlab'
#
#
#        $headers = @{
#            "PRIVATE-TOKEN" = "*****************"
#        }
#        $body = @{
#            "branch" = "main"
#            "commit_message" = "this is a commit"
#            "actions" = ""
#        }
#        Invoke-RestMethod -Verbose -Header $headers -ContentType 'application/json' -Body ($body|ConvertTo-Json) -Method Post -Uri "https://gitlab.com/api/v4/projects/****/repository/commits"
#    }


    # Exit on invalid input
    else {
        Write-Host "Not a valid GitHub or GitLab link. Exiting script."
        exit
    }

    
    ##########
    # This section of code is intended to allow the user to view the contents of their source code directory to verify their URL input
    ##########


    # Call the GitHub API to get information about the root directory
    try {
    $remoteFileList = Invoke-RestMethod $API_URL -UseBasicParsing -ErrorAction Stop
    }

    catch {
        ""
        Write-Host "An Error occured when attempting to access the URL. Please check your input and try again."
        ""
        "ERROR MESSAGE: $($Error[0])"
        exit
    }


    # Creates an array to store root directory information
    $remoteFileListArray = @()
    $remoteFileListArray = $remoteFileList -split ' '


    # Displays the names of files and directories in the root directory. Also formats the output to be cleaner.
    ""
    Write-Host "Files found in directory:"
    $remoteFileListArray | Where-Object {$_ -like '*name*'} | ForEach-Object {$_.Substring(7)}

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
                $hyperlink_base = '$sourceFolder/blob/main/'
                Write-Host "Hyperlink format is $sourceFolder/blob/main/{path}"

            exit
            }

            ##########
            # Handling GitLab Hyperlink Creation
            ##########

            elseif ($type -eq 'gitlab') {
            }

            else {
                exit
            }
        }

    # Exit code if [y] is not the input
        elseif ($confirmation -eq 'n') {
            Write-Host "Exiting script. Please rerun the script to try again."
        }

        else {
            Write-Host "Invalid input. Exiting script."
            exit
        }
            
    Write-Host "confirmed"
}



#####################################################################################
# This part of the code handles local source code locations (integrates with VSCode)#
#####################################################################################

else {

    try {

        # Lists files in the path of the source folder
        Get-ChildItem -Path "$sourceFolder" -ErrorAction Stop
        ""

        # [y/n] Confirmation Prompt
        $confirmation = Read-Host "Does this look correct? [y/n]"


            # Proceed if [y] is the input
            if ($confirmation -eq 'y') {
                Write-Host "Confirmed"


                # This section of the code generates the hyperlink based on the input path
                $hyperlink_base = 'vscode://file/$sourceFolder\'
                Write-Host 'Hyper link format is vscode://file/$sourceFolder\{filename}'


                exit
            }

        # Exit code if [y] is not the input
            elseif ($confirmation -eq 'n') {
                Write-Host "Exiting script. Please rerun the script to try again."
            }

            else {
                Write-Host "Invalid input. Exiting script."
                exit
            }
            
        Write-Host "confirmed"
    }


    # Error Catching for invalid file paths
    catch {
        ""
        Write-Host "An Error occured. Please check your input and try again."
        ""
        "ERROR MESSAGE: $($Error[0])"
        exit
    }
}