**What is SCAMR Helper?**

SCAMR Helper is a PowerShell script designed to take in raw Static Code Analysis (SCA) CSV result files and modify them to generate a modified CSV file that has a hyperlink that will directly link to each finding's relevant line of code.

It currently supports generating hyperlinks for:



- Local repositories in VSCode

- Remote GitHub repositories

- Remote GitLab repositories



**How do I use it?**

It's pretty easy to use!

1. Download SCAMR\_Helper.ps1

2. Run the script in PowerShell with .\\SCAMR\_Helper.ps1

3. Enter the local file path or GitHub/GitLab link containing your source code

4. Select a SCA results CSV file that you wish to modify to contain hyperlinks.

5. The script will automatically generate hyperlinks based on the file path or URL you inputted in step 3!

6\. Open the generated CSV file in Excel to be able to use the generated hyperlink to access each line of source code referenced in your findings.

