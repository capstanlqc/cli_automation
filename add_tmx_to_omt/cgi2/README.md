# CGI2 -- Adding COG TMs to CG OMT

This script will fetch master TMs from an COG OmegaT project and add them to an CG OmegaT project,  under `/tm/auto/COG`.

* Author:      Adrien Mathot      
* Creation:    2020/05/15    

## Legend 

| Abbreviation              | Meaning                       |
|:-----------------------|:---------------------------------|
| CG            | Coding Guide                        |
| COG           | Cognitive Units              |

## Files 

The script can be found at `U:\PISA_2021\FIELD_TRIAL`. The file is called `CGI2.sh`.

## Steps

1. Put the CG OMT package from the PISA portal in the `CCC_lll/4_CODING_GUIDES/00_FROM_ETS/` folder (for example `ESP_esp/4_CODING_GUIDES/00_FROM_ETS/`)
2. Run the script
3. Once the script has started it will ask you for the language code **in CCC_lll format** (example `ESP_esp`)
4. The script will show you a list of domains, select the domain for which you want to update the CG package (e.g. 3 for New Math)
5. The script will check that the CG package exists, and will check if there are no duplicate packages in the COG projects. If there is a problem the script will exit
6. The script updates the CG package for the selected domain
7. You can find the updated package in `CCC_lll/4_CODING_GUIDES/00_TO_COUNTRY`/ (example `ESP_esp/4_CODING_GUIDES/00_TO_COUNTRY/`)

## Support

For any issues or questions, please contact  [Adrien Mathot](adrien.mathot@capstan.be).
