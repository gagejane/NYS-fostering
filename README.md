# **Analyzing Annual NYS Foster Care Data**

## Jane Stout, Ph.D.
#### Updated June 1 2019

The New York State [(NYS) Children in Foster Care Annually database] contains information on the total number of admissions, discharges, and children in foster care, the type of care, and total Child Protective Services (CPS) reports indicated each year in the state. The data have been collected from 1994-2017. I used R programming language to conduct the analyses and visualizations in this report (the code is found [here](code.R)).

As seen in Figure 1, there is a wide discrepancy in the number of annual CPS reports and the number of children who are actually admitted to foser care . Specifically, the rate at which children are admitted to foster care is far lower than the rate at which CPS Reports occur. For instance, in 2017, while 46,726 CPS Reports were filed, only 8,375 children were actually admitted to foster care. This trend is consistent with the [CPS's guide for parents], indicating that "...a report is a statement of concern; it is not an accusation." That is, a CPS report is a starting place for an investigation, which may or may not result in a child being put in foster care. **The data in Figure 1 indicate that most CPS reports do not result in admission into foster care.**

**Figure 1. Number of Children in Foster Care and CPS Reports in the State of New York Over Time**

![](images/NYS_mulitline.png)

We can look at the rate at which CPS reports occur and the rate at which children are admitted into foster care by NYS counties. See Figure 2a and 2b, respectively, for rates in 2017. These figures show that CPS reporting and foster care admittance are particularly concentrated in some counties (e.g., New York City). Further, higher CPS reporting rates tend to be more strongly associated with higher foster admittance (i.e., darker shaded counties tend to co-occur in Figures 2a and 2b).

**Figure 2a. Number of CPS Reports in New York State Counties in 2017**

![](images/CPS_heat1.png)

**Figure 2b. Number of Children Admitted into Foster Care in New York State Counties in 2017**

![](images/Admitted_heat.png)

When we observe the rate at which CPS reporting and foster admittance have occurred over time for counties with the top five CPS reporting rates in 2017, we see that New York City has the most activity (see Figures 3a and 3b). Consistent with Figure 1, while foster admittance has declined over time, CPS reporting has not. Rather, CPS reporting appears to be increasing over time.

**Figure 3a. Count of CPS Reports in Top Five New York State Counties Over Time**.

![](images/top_five_CPS1.png)

**Figure 3b. Number of Children Served in Top Five New York Counties Over Time**

![](images/top_five_admitted.png)

Children are placed in a variety of foster home environments, including the following:

- **Adoptive Home**
  - This includes adoptive and/or adoption subsidized homes.
- **Agency Operated Boarding Home**
- **Approved Relative Home**
  - The relative has been approved as a foster parent.
- **Foster Boarding Home**
- **Group Home**
  - Congregate Care home
- **Group Residence**
  - These are also considered congregate care for youth.
- **Institution**
  - This facility type is a larger facility for congregate care.
- **Supervised Independent Living**
  - Young adults have been approved by Office of Children and Family Services (OCFS) to live on their own.
- **Other**
  - Residential treatment facilities, skilled nursing facilities, specialized schools, etc.

As seen in Figure 4, children tend to spend the most time in foster boarding homes, followed by approved relatives' homes, followed by institutions.

**Figure 4. Number of Care Days Provided for Housing Arrangements in New York State in 2017**

![](images/housing.png)
## Summary

This analysis highlighted the following about the state of New York foster system:
1. There is not a 1:1 relationship between foster admission rates CPS reports; CPS reporting does not necessarily result in foster care admittance.
2. New York City shows by far the highest prevalence of CPS reports and fostering.
3. The most common type of foster housing is boarding homes, followed by approved relative homes and institutions.


[(NYS) Children in Foster Care Annually database]: https://www.kaggle.com/new-york-state/nys-children-in-foster-care-annually

[CPS's guide for parents]: https://www.preventchildabuseny.org/resour/parents/guide-child-protective-services
