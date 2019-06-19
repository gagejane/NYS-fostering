
### ----------------Required packages------------------------------------------- ###

r_packages <- '/Users/janestout/Dropbox/Projects/NYS-foster/nys-children-in-foster-care-annually/r_packages'
.libPaths(r_packages)

install.packages(c('ggplot2', 'maps', 'mapproj','car','rlang', 'scales', 'colorspace'))
require(ggplot2, quietly = TRUE, warn.conflicts = FALSE)
require(maps, quietly = TRUE, warn.conflicts = FALSE)
require(mapproj, quietly = TRUE, warn.conflicts = FALSE)
require(car, quietly = TRUE, warn.conflicts = FALSE)

#info for parents about CPS: https://www.preventchildabuseny.org/resour/parents/guide-child-protective-services
file <- '/Users/janestout/Dropbox/Projects/NYS-foster/children-in-foster-care-annually-beginning-1994.csv'
df <-read.csv(file)
attach(df)

#Create dataframes, aggregating across Year
df_CPS <- aggregate(Indicated.CPS.Reports ~ Year, df, sum)
df_CPS$Activity <- 'CPS'
df_CPS$Count <- df_CPS$Indicated.CPS.Reports
drops <- c('Indicated.CPS.Reports')
df_CPS <- df_CPS[, !(names(df_CPS) %in% drops)]

# df_Served <- aggregate(Number.of.Children.Served ~ Year, df, sum)
# df_Served$Activity <- 'Fostered'
# df_Served$Count <- df_Served$Number.of.Children.Served
# drops <- c('Number.of.Children.Served')
# df_Served <- df_Served[, !(names(df_Served) %in% drops)]

df_Admit <- aggregate(Admissions ~ Year, df, sum)
df_Admit$Activity <- 'Admitted'
df_Admit$Count <- df_Admit$Admissions
drops <- c('Admissions')
df_Admit <- df_Admit[, !(names(df_Admit) %in% drops)]
                       
#Merge dataframes together; add cases
combined <- rbind(df_Admit, df_CPS)
str(combined)
combined_2017 <-combined[which(Year==2017),]

attach(combined)
#Multiline plot of Admissions, Discharges, and CPS Reports across time
#change order of legend items: https://www.datanovia.com/en/blog/ggplot-legend-title-position-and-labels/
png(file='/Users/janestout/Dropbox/Projects/NYS-foster/nys-children-in-foster-care-annually/images/NYS_mulitline.png', height = 600, width=800)
ggplot(combined, aes(Year, Count, colour=Activity)) + theme_classic() +
  geom_line() + geom_point() + ggtitle('Number of Children Admitted into Care and \n CPS Reports in the State of New York Over Time')+
  theme(plot.title = element_text(size=24, face='bold', hjust=.5),
        axis.title = element_text(size=20, face='bold'),
        axis.text = element_text(size=16),
        legend.title = element_text(size=20, face='bold'),
        legend.text = element_text(size=16),
        axis.text.x = element_text(angle=70, hjust=1))+
  guides(color = guide_legend(reverse = TRUE))+
  scale_x_continuous(breaks=Year) 
dev.off()

#Create a subset of the data: 2017 only
df_2017 <- subset(df, Year == 2017)

#SOURCES
#CREATE COUNTY MAP: https://stackoverflow.com/questions/34843932/how-to-create-a-county-map-with-select-counties-highlighted
#HEATMAP: https://stackoverflow.com/questions/24441775/how-do-you-create-a-us-states-heatmap-based-on-some-values
county_df <- map_data('county')  # mappings of counties by state
countyMap <- subset(county_df, region=="new york")   # subset just for NYS
countyMap$county <- countyMap$subregion

#make sure county names are consistent across the map package the data source from NY State
county <- unique(countyMap$subregion)
analysis <- unique(tolower(df_2017$County))

xtab_set <- function(analysis,county){
  both <- union(analysis,county)
  in_analysis <- both %in% analysis
  in_county <- both %in% county
  return(table(in_analysis,in_county))
}

xtab_set(analysis,county)
setdiff(county, analysis)
setdiff(analysis,county)

#st. lawrence has a period in the CPS data but not in the map package
countyMap$subregion <- gsub('st ', 'st. ', countyMap$subregion)

#CPS data aggregates data across all boroughs of NYcity; map package make them distinct
#recode each borough in the map package so that they are each called 'new york city', 
#all give boroughs will show the same number of CPS reports and Admissions
countyMap$subregion <- gsub('bronx', 'new york city', countyMap$subregion)
countyMap$subregion <- gsub('kings', 'new york city', countyMap$subregion)
countyMap$subregion <- gsub('new york', 'new york city', countyMap$subregion)
countyMap$subregion <- gsub('queens', 'new york city', countyMap$subregion)
countyMap$subregion <- gsub('richmond', 'new york city', countyMap$subregion)
countyMap$subregion <- gsub('new york city city', 'new york city', countyMap$subregion)

#import table of county populations and make sure counties are spelled the same as CPS counties
file <- '/Users/janestout/Dropbox/Projects/NYS-foster/counties.csv'
df_pop <-read.csv(file, stringsAsFactors = FALSE)
df_pop$Population <- as.numeric(gsub(',', '', df_pop$Population))

pop <- tolower(df_pop$County)
pop <- gsub(' county', '', pop)
pop

xtab_set <- function(analysis,pop){
  both <- union(analysis,pop)
  in_analysis <- both %in% analysis
  in_pop <- both %in% pop
  return(table(in_analysis,in_pop))
}

xtab_set(analysis,pop)
setdiff(pop, analysis)
setdiff(analysis,pop)

my_vars <- c('County','Population')
df_pop_cleaned <-df_pop[my_vars]
kings <- as.numeric(df_pop_cleaned[1,'Population'])
queens <- as.numeric(df_pop_cleaned[2,'Population'])
ny <- as.numeric(df_pop_cleaned[3,'Population'])
bronx <- as.numeric(df_pop_cleaned[5,'Population'])
richmond <- as.numeric(df_pop_cleaned[10,'Population'])
nyc <- kings+queens+ny+bronx+richmond
df_pop_cleaned <- df_pop_cleaned[-c(1,2,3,5,10),]
df_pop_cleaned[nrow(df_pop_cleaned)+1,] <- list('new york city',nyc)
df_pop_cleaned$County <- gsub(' County', '', df_pop_cleaned$County)
df_pop_cleaned$County <- toupper(df_pop_cleaned$County)
df_pop_cleaned

#CPS
df_county_CPS_2017 <- aggregate(Indicated.CPS.Reports ~ County, df_2017, sum)
df_county_CPS_2017$subregion <- tolower(df_county_CPS_2017$County)
df_county_CPS_2017$Count_CPS <- df_county_CPS_2017$Indicated.CPS.Reports
df_county_CPS_2017 <- merge(df_county_CPS_2017, df_pop_cleaned, by='County')
# df_county_CPS_2017$prop <- df_county_CPS_2017$Count/df_county_CPS_2017$Population

# map.df <- merge(countyMap, df_county_CPS_2017, by='subregion', all.x=T)
# map.df <- map.df[order(map.df$order),]
# #breaks <- quantile(df_county_CPS_2017$Count, probs = seq(0, 1, length.out = n))
# #breaks <- seq(min(df_county_CPS_2017$Count), max(df_county_CPS_2017$Count), length=10)
# #limits <- c(min(df_county_CPS_2017$Count), max(df_county_CPS_2017$Count))
# #scale_fill_gradientn(colours=rev(heat.colors(200)),na.value='grey90', breaks = seq(min(df_county_CPS_2017$Count), max(df_county_CPS_2017$Count), length=200))+
#   
# 
# png(file='/Users/janestout/Dropbox/Projects/NYS-foster/nys-children-in-foster-care-annually/images/CPS_heat1.png', height = 600, width=800)
# ggplot(map.df, aes(x=long, y=lat, group=group))+
#   ggtitle('Number of CPS Reports in \n New York State Counties in 2017')+theme_classic()+
#   xlab("Longitude") +
#   ylab('Latitude')+
#   geom_polygon(aes(fill=Count_CPS))+
#   geom_path()+
#   theme(plot.title = element_text(size=14, face='bold', hjust=.5))+
#   scale_fill_gradientn(colours=rev(heat.colors(200)),na.value='grey90')+
#   coord_map()+
#   theme(
#     plot.title = element_text(size=24, face='bold', hjust=.5),
#     axis.title = element_text(size=20, face='bold'),
#     axis.text = element_text(size=16),
#     legend.title = element_text(size=20, face='bold'),
#     legend.text = element_text(size=16),
#     panel.border = element_blank()
#   )
# dev.off()

#Number Admitted
df_county_admit_2017 <- aggregate(Admissions ~ County, df_2017, sum)
df_county_admit_2017$subregion <- tolower(df_county_admit_2017$County)
df_county_admit_2017$Count_Admit <- df_county_admit_2017$Admissions

# map.df <- merge(countyMap, df_county_admit_2017, by='subregion', all.x=T)
# map.df <- map.df[order(map.df$order),]
# 
# png(file='/Users/janestout/Dropbox/Projects/NYS-foster/nys-children-in-foster-care-annually/images/Admitted_heat.png', height = 600, width = 800)
# ggplot(map.df, aes(x=long, y=lat, group=group))+
#   ggtitle('Number of Children Admitted to Foster Care \n in New York State Counties in 2017')+theme_classic()+
#   xlab("Longitude") +
#   ylab('Latitude')+
#   geom_polygon(aes(fill=Count_Admit))+
#   geom_path()+
#   theme(plot.title = element_text(size=14, face='bold', hjust=.5))+
#   scale_fill_gradientn(colours=rev(heat.colors(200)),na.value='grey90')+
#   coord_map()+
#   theme(
#     plot.title = element_text(size=24, face='bold', hjust=.5),
#     axis.title = element_text(size=20, face='bold'),
#     axis.text = element_text(size=16),
#     legend.title = element_text(size=20, face='bold'),
#     legend.text = element_text(size=16),
#     panel.border = element_blank()
#   )
# dev.off()


#Proportion CPS/admitted
df_county_merged_2017 <- merge(df_county_CPS_2017, df_county_admit_2017, by='subregion')
df_county_merged_2017$Proportion <- df_county_merged_2017$Count_Admit/df_county_merged_2017$Count_CPS
df_county_merged_2017 <- df_county_merged_2017[order(-df_county_merged_2017$Proportion),]

map.df <- merge(countyMap, df_county_merged_2017, by='subregion', all.x=T)
map.df <- map.df[order(map.df$order),]

png(file='/Users/janestout/Dropbox/Projects/NYS-foster/nys-children-in-foster-care-annually/images/prop_heat.png', height = 600, width = 800)
ggplot(map.df, aes(x=long, y=lat, group=group))+
  ggtitle('Proportion of Children Admitted to Foster Care Given the \nNumber of CPS Reports, by County, in 2017')+theme_classic()+
  xlab("Longitude") +
  ylab('Latitude')+
  geom_polygon(aes(fill=Proportion))+
  geom_path()+
  theme(plot.title = element_text(size=14, face='bold', hjust=.5))+
  scale_fill_gradientn(colours=rev(heat.colors(20)),na.value='grey90')+
  coord_map()+
  theme(
    plot.title = element_text(size=24, face='bold', hjust=.5),
    axis.title = element_text(size=20, face='bold'),
    axis.text = element_text(size=16),
    legend.title = element_text(size=20, face='bold'),
    legend.text = element_text(size=16),
    panel.border = element_blank()
  )
dev.off()

#plotting source https://www.r-graph-gallery.com/275-add-text-labels-with-ggplot2/
options(scipen=2)
png(file='/Users/janestout/Dropbox/Projects/NYS-foster/nys-children-in-foster-care-annually/images/prop_pop.png', height = 600, width = 1200)
ggplot(df_county_merged_2017, aes(x=Proportion, y=Population)) +
  ggtitle('Proportion of Children Admitted to Foster Care \nGiven the Number of CPS Reports by County and Population in 2017')+theme_classic()+
  xlab("Proportion Admitted/CPS Reports") +
  ylab('County Population')+
  geom_point(
    color="red",
    fill="blue",
    shape=1,
    alpha=0.5,
    size=2,
    stroke = 2
  )+
  theme(
    plot.title = element_text(size=24, face='bold', hjust=.5),
    axis.title = element_text(size=20, face='bold'),
    axis.text = element_text(size=16),
    legend.title = element_text(size=20, face='bold'),
    legend.text = element_text(size=16),
    panel.border = element_blank()
  ) +  geom_label(label = df_county_merged_2017$County.x, colour = "darkviolet", fontface = "bold", size=4)
dev.off()


#DISPLAY TOP FIVE COUNTIES OVER TIME
#CPS
df_county_CPS <- aggregate(Indicated.CPS.Reports ~ County, df, sum)
df_county_CPS$subregion <- tolower(df_county_CPS$County)
df_county_CPS$Count <- df_county_CPS$Indicated.CPS.Reports
data <- df_county_CPS[order(-df_county_CPS$Count),]

counties <- c('NEW YORK CITY', 'SUFFOLK', 'ERIE', 'NASSAU', 'MONROE')
ds <- subset(df, County %in% counties)
ds$Count <- ds$Indicated.CPS.Reports

png(file='/Users/janestout/Dropbox/Projects/NYS-foster/nys-children-in-foster-care-annually/images/top_five_CPS1.png', height = 600, width = 800)
ggplot(ds, aes(x=Year, y=Count, fill=County))+theme_classic()+
  geom_area()+
  ggtitle('Count of CPS Reports in Top Five \n New York State Counties Over Time')+
  theme(
    plot.title = element_text(size=24, face='bold', hjust=.5),
    axis.title = element_text(size=20, face='bold'),
    axis.text = element_text(size=16),
    axis.text.x = element_text(angle=70, hjust=1),
    legend.title = element_text(size=20, face='bold'),
    legend.text = element_text(size=16),
    panel.border = element_blank()
  )+
  scale_x_continuous(breaks=Year)
dev.off()  

ds$Count <- ds$Admissions

png(file='/Users/janestout/Dropbox/Projects/NYS-foster/nys-children-in-foster-care-annually/images/top_five_admitted.png', height = 600, width = 800)
ggplot(ds, aes(x=Year, y=Count, fill=County))+theme_classic()+
  geom_area()+
  ggtitle('Number of Children Admitted to Foster Care in \n Top Five New York State Counties Over Time')+
  theme(
    plot.title = element_text(size=24, face='bold', hjust=.5),
    axis.title = element_text(size=20, face='bold'),
    axis.text = element_text(size=16),
    axis.text.x = element_text(angle=70, hjust=1),
    legend.title = element_text(size=20, face='bold'),
    legend.text = element_text(size=16),
    panel.border = element_blank()
  )+
  scale_x_continuous(breaks=Year)
dev.off()  

#png(file='/Users/janestout/Dropbox/nys-children-in-foster-care-annually/scatter.png', height = 800, width=800)
#ggplot(df_2017, aes(x=log_CPS, y=log_Served, size=Number.of.Children.Served, color=log_CPS))+
#  geom_point(alpha=.3)+
#  scale_colour_continuous(guide = FALSE) +
#  ggtitle('Relationship between Number of Children Served \n and CPS Reports in 2017')+
#  xlab("Log base 10 number of CPS Reports") +
#  ylab('Log base 10 number of Childred Served')+
#  labs( size = "# Children Served" ) +
#  theme_bw() +
#  theme(
#    plot.title = element_text(size=24, face='bold', hjust=.5),
#    axis.title = element_text(size=20, face='bold'),
#    axis.text = element_text(size=20),
#    legend.position = c(.95, .05),
#    legend.justification = c("right", "bottom"),
#    legend.title = element_text(size=20, face='bold'),
#    legend.text = element_text(size=20),
#    panel.border = element_blank()
#  )
#dev.off()

#Plot different housing frequencies in 2017

sums <- aggregate(x = df_2017[c("Adoptive.Home", 
                                "Agency.Operated.Boarding.Home",
                                "Approved.Relative.Home",       
                                "Foster.Boarding.Home",         
                                "Group.Home",                   
                                "Group.Residence",              
                                "Institution",                  
                                "Other",                        
                                "Supervised.Independent.Living")],
                  by = df_2017[c("Year")],
                  FUN = sum
)

houses <- data.frame(Housing = c("Adoptive Home", 
                                 "Agency Operated Boarding Home",
                                 "Approved Relative Home",       
                                 "Foster Boarding Home",         
                                 "Group Home",                   
                                 "Group Residence",              
                                 "Institution",                  
                                 "Other",                        
                                 "Supervised Independent Living"))

drops <- c('Year')
sums <- sums[, !(names(sums) %in% drops)]

counts <- as.numeric(sums[1,]/1000000)
house_counts <- cbind(houses, counts)
house_counts <- house_counts[order(-house_counts$counts),]
house_counts$Housing <- factor(house_counts$Housing, levels=house_counts$Housing)

#The scipen option determines how likely R is to switch to scientific notation, 
#the higher the value the less likely it is to switch. 
#Set the option before making your plot, if it still has scientific notation, 
#set it to a higher number.
options(scipen=2)
png(file='/Users/janestout/Dropbox/Projects/NYS-foster/nys-children-in-foster-care-annually/images/housing.png', height = 600, width = 800)
ggplot(house_counts, aes(x=house_counts$Housing, y=house_counts$counts))+theme_classic()+
  geom_point(size=5, color='#FF6347')+
  geom_segment( aes(x=house_counts$Housing, xend=house_counts$Housing, y=0, yend=house_counts$counts))+
  coord_flip()+
  ggtitle('Number of Care Days Provided for Housing \n Arrangements in New York State in 2017')+
  theme(
    plot.title = element_text(size=24, face='bold', hjust=.5),
    axis.title = element_text(size=20, face='bold'),
    axis.text = element_text(size=14),
    axis.text.y = element_text(size=14, face='bold'),
    panel.border = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.grid.major.y = element_blank(),
    legend.position="none"
  )+
  xlab('')+
  ylab('Number of Care Days (in millions)')
dev.off() 
