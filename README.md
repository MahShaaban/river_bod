# river_bod
Analysis of public data of river organic pollution in South Korea. 

# Overview  
This is a quick [Exploratory Data Analysis (EDA)](https://en.wikipedia.org/wiki/Exploratory_data_analysis) of a public dataset of [Biochemical Oxygen Demand (BOD)](https://en.wikipedia.org/wiki/Biochemical_oxygen_demand) measurements from 7 spots somewhere in South Korea in the period form 1992 to 2016 :) The aim of this analysis is to find the **missing values** to assess the reliabiltiy of the measurements, the **distribution** of the BOD values at different sites and finally the major **trends** over time.  

# Datasets
The following datasets used in the analysis are:
  
  1. [river_metadata.csv](https://github.com/MahShaaban/river_bod/blob/master/data/river_metadata.csv) This is a metadata about the measurements' spots. This dataset consist of 4 columns:  
      - `river_id` which is obviously the river ID  
      - `river_name` this on isn't obvious at all and wouldn't even read out on my computer :(  
      - `north` the 'N' coordinate of the site in the formate (degree.minute.seconds)  
      - `east` the 'E' coordinate of the site in the formate (degree.minute.seconds)  
      
  2. [bod.csv](https://github.com/MahShaaban/river_bod/blob/master/data/bod.csv) This is the measurements (BOD) from the period from 1992 to 2016. This dataset consist of 7 columns and 300 rows. Eache represnet a single BOD measurement each month for 25 years at a particular site. 
  
  3. [score.csv](https://github.com/MahShaaban/river_bod/blob/master/data/score.csv) This is some score and a category - that I don't understand :P  
      - `river_id` the same river IDs mentioned above  
      - `score` some number!  
      - `category` a category based on the number much like an elementary school grade category (excellent, good, fair)  

# EDA
## Missing values

  1. Proportion of missing data ![Figure 1](figures/fig1.png)  
  2. Total percent of missing data ![Figure 2](figures/fig2.png)  

## Distributions

  3. Distribution of BOD measurements ![Figure 3](figures/fig3.png)  
  4. Distribution of log BOD measurements ![Figure 4](figures/fig4.png)  
  5. Distribution of BOD per river ![Figure 5](figures/fig5.png)  
  6. Distribution of log BOD per river ![Figure 6](figures/fig6.png)  
  7. Distribution of BOD per river over time ![Figure 7](figures/fig7.png)  
  
## Trends  

  8. Average BOD over time ![Figure 8](figures/fig8.png)  
  9. Average BOD over time (LOESS smoothed) ![Figure 9](figures/fig9.png)  
  10. Contribution of rivers to the total BOD ![Figure 10](figures/fig10.png)  
  11. Average BOD per month ![Figure 11](figures/fig11.png)  
  12. Average BOD per month (LOESS smoothed) ![Figure 12](figures/fig12.png)  
  
## Maps

  13. Scores and categories map ![Figure 13](figures/fig13.png)  
  
# Conclusions  
It's too late/early to make any conclustions!  
