OpenXY
======
Matlab tool for performing cross-correlation analysis of EBSD patterns using real and simulated patterns.
Calculates dislocation density.

Files Needed:
Scan Files (.ang and .txt, or .ctf and .cpr)
EBSD scan images

To Run:
Matlab Version: 2012a or later (for parallel processing). 2014a or later reccommended.
Open and run Run_OpenXY.m

To Clone:
This repository includes a submodule. To clone with the submodule run the following commands in the root directory of the repository:
git submodule init
git submodule update
OR clone the whole repository at once with the --recursive argument
git clone --recursive https://github.com/BYU-MicrostructureOfMaterials/OpenXY.git

In case of an error:
Please open an issue on this repository detailing your error, or write an email to BYUOpenXY@gmail.com with "Error Report" in subject. 
Be specific and copy the error message into the body of the email or issue report, including any applicable screenshots.
Attach the Settings.mat file immediately after the error has occured to include the settings used for the analysis.

Acknowledgement:

US Deparment of Energy grant number DE-SC0012587

DISCLAIMER:
This software is still in development. The writers will not be responsible for any loss of data or negative consequences that may
result from running the program. Use at your own risk.
