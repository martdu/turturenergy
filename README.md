# Vacuum Energy
Prof. Dr. rer. nat. Claus W. Turtur researched in the field of vacuum energy or zero-point-energy. According to his research it is possible to convert the energy of the zero-point-oscillations of the quantum vacuum into classical mechanical energy (electrostatic rotor experiment). Furthermore due to the finite propagation velocity of electromagnetic waves (maybe caused by the vacuum energy) it is possible to develop systems that convert the energy of the vacuum into electrical and mechanical energy in a usable range of power. His simulations of EMDR-Converter (electro-mechanical-double-resonance-converter) show power outputs in the kilowatt range.

The directory "originals" contains all the simulation calculations from his paper series "1_Serie-deutsch-5Artikel.pdf" (or "1_Series-english-5Articles.pdf").

You can find some of his research including the mentioned papers here: https://web.archive.org/web/20180917161851/https://www2.ostfalia.de/cms/de/pws/turtur/FundE.

And here you'll find the updated and corrected paper in section 3: https://www.ostfalia.de/cms/en/pws/turtur/details-in-physics/.

"program_04" contains the EMDR-Converter (electro-mechanical-double-resonance-converter) simulation program.

## Lazarus IDE specific information (Free Pascal)
If you want to run the programs with a free pascal compiler and IDE instead of using the proprietary Delphi IDE by Borlands, you should use Lazarus IDE (https://www.lazarus-ide.org/). It uses the FPC, free pascal compiler.

After downloading and installing Lazarus you have to convert the .pas files into a Lazarus project (.lpr, this will create multiple files): 

Open the .lpr or .pas file with Lazarus. Then: Project -> New Project from File -> Select .pas or any Delphi file.

The directory "lazarus" already contains the .lpr files, which are essentially the same as .pas files.

Then compile the program. It will detect an error stating it cannot find the Graphics and Interface module.

You have to include the LCLBase and LCL package in the project inspector: 

Project -> Project inspector -> Add -> New requirement -> Choose LCLBase and also choose LCL.

All variables of data type Real48 are changed to be Double types, otherwise errors occur. This code change is already done in the code in directory "lazarus".
There could occur an error in "program_04/KM_009i.lpr", probably because of some assignment statements on files (schonda).

## Telegram Group for questions and discussion
If you have any questions regarding Vacuum Energy, the Software etc. feel free to join the Telegram group "Vacuum Energy Claus W. Turtur" through the following link: https://t.me/joinchat/H1wG1h0fGV_Ehk6U5ciD4A.
