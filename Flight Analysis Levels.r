# 0 Prepare R

# 0.1 Set libraries
library(tidyr)
library(dplyr)
library(ggplot2)
library(magrittr)
library(png)
library(grid)
library(extrafont)

# 0.2 Set working directory
setwd('C:\\Users\\Guillaume\\Documents\\Nes\\Duck-Hunt')

# 0.3 Read dataset made using (Flight Tracking2.lua)
df.FlightTracking = read.csv('FlightTracking2.tsv', sep = '\t')












# 1 Size of hitboxes
# 1.1 Prepare the data
df.FlightTracking.2 = 
	df.FlightTracking %>%
	filter(!(xmax >= 248 & xmin <= 14) & !(ymax >= 248 & ymin <= 14) ) %>% #remove lines that have boxes on both sides of the screen
	mutate(Area = (xmax-xmin+8)*(ymax-ymin+8)) #add 8 for the width of individual boxes

# 1.2 Plot the data
ggplot() +
	geom_point( data = df.FlightTracking.2, aes(x = level, y = Area), alpha = 0.025)+
	geom_line(stat="smooth", data = df.FlightTracking.2 %>% filter(level <= 23), aes(x = level, y = Area), color = '#A8000F', method = 'gam', size = 1.5, alpha = 0.8, formula = y ~ s(x, bs = "cs"))+
	geom_line(stat="smooth", data = df.FlightTracking.2 %>% filter(level %in% 24:26), aes(x = level, y = Area), color = '#A8000F', method = 'loess', size = 1.5, alpha = 0.8)+
	geom_line(stat="smooth", data = df.FlightTracking.2 %>% filter(level >  26), aes(x = level, y = Area), color = '#A8000F', method = 'gam', size = 1.5, alpha = 0.8, formula = y ~ s(x, bs = "cs"))+
	theme_bw()+
	scale_x_continuous(expand = c(0.05, 0.05))+
	scale_y_continuous(expand = c(0.05, 0.05), name = bquote('Area (pixel'*s^2*')'))+
	theme(
		text=element_text(family="8bit",size = 16),  #8bit font by http://fontvir.us
		panel.grid.major.x = element_blank(),
		panel.grid.major.y = element_line(linetype = 'dashed', color = 'grey70'),
		panel.grid.minor = element_blank(),
		panel.border  = element_rect(colour = "white"),
		axis.line = element_line(color = 'grey30', arrow = arrow())
		
	)	
# 1.2.1 Save the graph
ggsave('g1.png')

# 1.3 Specific computations
# 1.3.1 Average hitbox size after level 26
df.FlightTracking.2 %>%
filter(level >= 27) %>%
{mean(.$Area)}












# 2 Speed of ducks
# 2.1 Prepare the data	
df.FlightTracking.Speed = 
	df.FlightTracking %>%
	filter(!(xmax >= 248 & xmin <= 14) & !(ymax >= 248 & ymin <= 14) ) %>%#remove lines that have boxes on both sides of the screen
	mutate(
		Mid.x = (xmax + xmin + 7)/2, #compute the middle of the duck
		Mid.y = (ymax + ymin + 7)/2
	) %>%
	group_by(Iteration) %>%
	mutate(Speed = ((Mid.x-lag(Mid.x))^2+(Mid.y-lag(Mid.y))^2)^0.5) %>% # use the previous line to compute the speed
	filter(!is.na(Speed))
	
# 2.2 Plot the data
ggplot() +
	geom_point(data = df.FlightTracking.Speed, aes(x = level, y = Speed*60/8), alpha = 0.05)+
	geom_line(stat="smooth", data = df.FlightTracking.Speed, aes(x = level, y = Speed*60/8), size = 1.5, alpha = 0.8, method = 'gam', formula = y ~ s(x, bs = "cs"), color = '#BC00BC')+
	theme_bw()+
	scale_x_continuous(expand = c(0.01, 0.05))+
	scale_y_continuous(expand = c(0, 0.05), name = 'Speed (pixels/second)')+
	theme(
		text=element_text(family="8bit",size = 16),  #8bit font by http://fontvir.us
		panel.grid.major.x = element_blank(),
		panel.grid.major.y = element_line(linetype = 'dashed', color = 'grey70'),
		panel.grid.minor = element_blank(),
		panel.border  = element_rect(colour = "white"),
		axis.line = element_line(color = 'grey30', arrow = arrow())
	)	
# 2.2.1 Save the graph
ggsave('g2.png')

# 2.3 Specific computations
# 2.3.1 Average speed at level 1
df.FlightTracking.Speed %>%
filter(level == 1) %>%
{mean(.$Speed)*60/8}

# 2.3.2 Average speed level 8
df.FlightTracking.Speed %>%
filter(level == 8) %>%
{mean(.$Speed)*60/8}
	
# 2.3.3 Average speed level 12
df.FlightTracking.Speed %>%
filter(level == 12) %>%
{mean(.$Speed)*60/8}

# 2.3.4 Average speed level >= 27
df.FlightTracking.Speed %>%
filter(level >= 27) %>%
{mean(.$Speed)*60/8}












# 3 Flight duration
# 3.1 Prepare the data	
df.FlightTracking.Time = 
	df.FlightTracking %>%
	group_by(Iteration) %>%
	filter(last(Time)==Time)

# 3.2 Plot the data
ggplot() +
	geom_point(data = df.FlightTracking.Time, aes(x = level, y = Time/60), alpha = 0.4)+
	geom_line(stat="smooth", data = df.FlightTracking.Time, aes(x = level, y = Time/60), method = 'gam', formula = y ~ s(x, bs = "cs"), color = '#005000', size = 1.2, alpha = 0.8)+
	# facet_grid(DuckType~.)+
	theme_bw()+
	scale_x_continuous(expand = c(0.01, 0.05))+
	scale_y_continuous(expand = c(0.01, 0.05), name = 'Duration (seconds)')+
	theme(
		text=element_text(family="8bit",size = 16),  #8bit font by http://fontvir.us
		panel.grid.major.x = element_blank(),
		panel.grid.major.y = element_line(linetype = 'dashed', color = 'grey70'),
		panel.grid.minor = element_blank(),
		panel.border  = element_rect(colour = "white"),
		axis.line = element_line(color = 'grey30', arrow = arrow())
	)
# 3.2.1 Save the graph
ggsave('g3.png')

# 3.3 Specific computations
# 3.3.1 Average duration at level 1
df.FlightTracking.Time %>%
filter(level == 1) %>%
{mean(.$Time)/60}

# 3.3.2 Average duration at level >= 20
df.FlightTracking.Time %>%
filter(level >= 20) %>%
{mean(.$Time)/60}