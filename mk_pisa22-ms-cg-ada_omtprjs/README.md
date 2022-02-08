# PISA2022MS CG: packages for adapting versions

This automatino creates the MS CG project packages including TMs from the MS ZZZ base project and from the projects for the national versions COG and FT CG. Please proceed as follows.

## Instructions

1. Go to folder `03_ZZZ_to_national` under path `PISA_2021` > `MAIN_SURVEY` > `02_MS_Coding_Guides` > `02_New_Math` > `02_Prepp`.
2. Put packages for a certain version in the `IN_*` folders, e.g.
	<!-- ```
	manuel@Ur:03_ZZZ_to_national$ tree -L 2
	.
	├── IN_COG_NATIONAL
	│   └── PISA2022MS_OMT_MATNew_esp-COL.omt
	├── IN_FT_NATIONAL
	│   ├── PISA2021FT_CodingGuide_MAT-New-6A_esp-COL_OMT.omt
	│   └── PISA2022FT_CodingGuide_MAT-New-Update_esp-COL_OMT.omt
	├── IN_MS_BASE_ZZZ
	│   └── PISA2022MS_CodingGuide_MAT-New_esp-ZZZ_en_OMT.omt
	├── OUT_MS_NATIONAL
	├── _tech
	└── versions.txt
	``` -->

    > `IN_COG_NATIONAL`: PISA2022MS_OMT_MATNew_esp-COL.omt\
	> `IN_FT_NATIONAL`: PISA2021FT_CodingGuide_MAT-New-6A_esp-COL_OMT.omt and PISA2022FT_CodingGuide_MAT-New-Update_esp-COL_OMT.omt\
	> `IN_MS_BASE_ZZZ`: PISA2022MS_CodingGuide_MAT-New_esp-ZZZ_en_OMT.omt

3. Add the version's PISA language code to the `versions.txt` file (in a new line), e.g. `esp-COL`.
4. Retrieve the new MS CG package for the version in question from `OUT_MS_NATIONAL`.
    > `OUT_MS_NATIONAL`: PISA2022MS_CodingGuide_MAT-New_esp-COL_en_OMT.omt

## TM configuration

TMs from the input projects will be added to the output project like so:

```
OUT_MS_NATIONAL/PISA2022MS_CodingGuide_MAT-New_esp-COL_en_OMT.omt/tm
├── auto
│   ├── PISA2021FT_CG_MAT-New-6A_esp-COL_OMT.tmx
│   └── PISA2022FT_CG_MAT-New-Update_esp-COL_OMT.tmx
├── enforce
│   └── DNT (...)
├── PISA2022MS_CG_MAT-New_esp-ZZZ.tmx
├── PISA2022MS_COG_MAT-New_esp-COL.tmx
└── tmx2source
    └── ES-MS.tmx
```

The priority for matches with equal score will be as follows, in descending order:

1. `PISA2021FT_CG` (auto-populated if 100% match)
2. `PISA2022MS_COG` (not auto-populated)
3. `PISA2022MS_CG` (not auto-populated)


