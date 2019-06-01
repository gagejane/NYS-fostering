#info for parents about CPS: https://www.preventchildabuseny.org/resour/parents/guide-child-protective-services
file <- '/Users/janestout/Dropbox/Projects/NYS-foster/children-in-foster-care-annually-beginning-1994.csv'
df <-read.csv(file)

#Getting to know the data
head(df)
str(df)
attach(df)
levels(County)

library(ggplot2)

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
png(file='/Users/janestout/Dropbox/Projects/NYS-foster/nys-children-in-foster-care-annually/images/NYS_mulitline.png', height = 600, width=800)
ggplot(combined, aes(Year, Count, colour=Activity)) + theme_classic() +
  geom_line() + geom_point() + ggtitle('Number of Children in Foster Care and \n CPS Reports in the State of New York Over Time')+
  theme(plot.title = element_text(size=24, face='bold', hjust=.5),
        axis.title = element_text(size=20, face='bold'),
        axis.text = element_text(size=16),
        legend.title = element_text(size=20, face='bold'),
        legend.text = element_text(size=16),
        axis.text.x = element_text(angle=70, hjust=1))+
  scale_x_continuous(breaks=Year) 
dev.off()

#Create a subset of the data: 2017 only
df_2017 <- subset(df, Year == 2017)

#SOURCES
#CREATE COUNTY MAP: https://stackoverflow.com/questions/34843932/how-to-create-a-county-map-with-select-counties-highlighted
#HEATMAP: https://stackoverflow.com/questions/24441775/how-do-you-create-a-us-states-heatmap-based-on-some-values

install.packages('maps')
library(maps)
install.packages('mapproj')
library(mapproj)


county_df <- map_data('county')  # mappings of counties by state
countyMap <- subset(county_df, region=="new york")   # subset just for NYS
countyMap$county <- countyMap$subregion

#CPS
df_county_CPS <- aggregate(Indicated.CPS.Reports ~ County, df, sum)
df_county_CPS$subregion <- tolower(df_county_CPS$County)
df_county_CPS$Count <- df_county_CPS$Indicated.CPS.Reports

map.df <- merge(countyMap, df_county_CPS, by='subregion', all.x=T)
map.df <- map.df[order(map.df$order),]

png(file='/Users/janestout/Dropbox/Projects/NYS-foster/nys-children-in-foster-care-annually/images/CPS_heat.png', height = 600, width=800)
ggplot(map.df, aes(x=long, y=lat, group=group))+
  ggtitle('Number of CPS Reports in \n New York State Counties in 2017')+theme_classic()+
  xlab("Longitude") +
  ylab('Latitude')+
  geom_polygon(aes(fill=Count))+
  geom_path()+
  theme(plot.title = element_text(size=14, face='bold', hjust=.5))+
  scale_fill_gradientn(colours=rev(heat.colors(10)),na.value='grey90')+
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

#Number Served
df_county_admit <- aggregate(Admissions ~ County, df, sum)
df_county_admit$subregion <- tolower(df_county_admit$County)
df_county_admit$Count <- df_county_admit$Admissions

map.df <- merge(countyMap, df_county_admit, by='subregion', all.x=T)
map.df <- map.df[order(map.df$order),]

png(file='/Users/janestout/Dropbox/Projects/NYS-foster/nys-children-in-foster-care-annually/images/Admitted_heat.png', height = 600, width = 800)
ggplot(map.df, aes(x=long, y=lat, group=group))+
  ggtitle('Number of Children Admitted to Foster Care \n in New York State Counties in 2017')+theme_classic()+
  xlab("Longitude") +
  ylab('Latitude')+
  geom_polygon(aes(fill=Count))+
  geom_path()+
  theme(plot.title = element_text(size=14, face='bold', hjust=.5))+
  scale_fill_gradientn(colours=rev(heat.colors(10)),na.value='grey90')+
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


#DISPLAY TOP FIVE COUNTIES OVER TIME

data <- df_county_CPS[order(-df_county_CPS$Count),]

counties <- c('NEW YORK CITY', 'SUFFOLK', 'ERIE', 'NASSAU', 'MONROE')
ds <- subset(df, County %in% counties)
ds$Count <- ds$Indicated.CPS.Reports

png(file='/Users/janestout/Dropbox/Projects/NYS-foster/nys-children-in-foster-care-annually/images/top_five_CPS.png', height = 600, width = 800)
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

png(file='/Users/janestout/Dropbox/Projects/NYS-foster/nys-children-in-foster-care-annually/images/top_five_served.png', height = 600, width = 800)
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

counts <- as.numeric(sums[1,])
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
  ylab('Number of Care Days')
dev.off() 