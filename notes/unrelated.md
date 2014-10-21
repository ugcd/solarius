## Load and analize data of unrealted invividuals

References:

* `SOLAR` man page [matrix](http://helix.nih.gov/Documentation/solar-6.6.2-doc/91.appendix_1_text.html#matrix)

From `SOLAR` man page [pedigree](http://helix.nih.gov/Documentation/solar-6.6.2-doc/91.appendix_1_text.html#pedigree):

> Usage:    load pedigree <filename> [-founders]   ; loads pedigree file
> 
> 
> If the pedigree file contains founders only, i.e. a set of
> unrelated individuals with no parental data, parent ID fields
> are not required.  In this case, the '-founders' option must
> be included in the load command.  If this option is specified
> but the pedigree file does contain parent ID fields, those
> fields will be ignored


From [gaw19/../kinship/01-create-kinship-solar.R](https://github.com/variani/gaw19/blob/master/relationship-matrices/kinship/01-create-kinship-solar.R)

```
### parse files
# pedindex.out format
#
# @ http://helix.nih.gov/Documentation/solar-6.6.2-doc/08.chapter.html#pedindex
#
# 1. IBDID: sequential ID used by all SOLAR commands
# 2. FIBDID: FATHER'S IBDID
# 3. MIBDID: MOTHER'S IBDID
# 4. SEX: SEX
# 5. MZTWIN: MZTWIN
# 6. PEDNO: sequential pedigree identification number
# 7. GEN: GENERATION NUMBER
# 8. ID: original ID

# phi2.gz format
#
# @ http://www.biostat.wustl.edu/genetics/geneticssoft/manuals/solar210/08.chapter.html
#
# 1. IBDID1: sequential ID by individual #1 based on the sequencing in pedindex.out
# 2. IBDID2: sequential ID by individual #2 based on the sequencing in pedindex.out
# 3. phi2: the kinship coefficient "phi" times 2, a term which occurs frequently in genetic covariance equations
# 4. delta7: delta7 from the Jacquard condensed coefficients of identity
```
