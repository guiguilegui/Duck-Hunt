# 0 Prepare R

# 0.1 Set libraries
library(dplyr)
library(ggplot2)
library(magrittr)
library(png)
library(grid)


# 0.2 Set working directory
setwd('C:\\Users\\Guillaume\\Documents\\Nes\\Duck-Hunt')

# 0.3 Read dataset made using (Flight Tracking.lua)
df.FlightTracking = read.csv('FlightTracking.tsv', sep = '\t')

# 0.4 Import background picture
basepng = readPNG("C:\\Users\\Guillaume\\Documents\\Nes\\Duck-Hunt\\Base.png", TRUE)










# 1 Hitbox composite
# 1.1 Get the number of unique times
unique_t = unique(df.FlightTracking$Time) %>% sort()

# 1.2 Initialize the resulting list of data frame
df.pixel.hit = 
	list(NA) %>%
	rep(length(unique_t))
	
# 1.3 Set the names of the elements in the list
names(df.pixel.hit) = paste0('t',unique_t)

# 1.4 Get the data frames of pixels that were in the hit boxes
for(tt in unique_t){

	df.pixel.hit[[paste0('t', tt)]] = 
		df.FlightTracking %>%
		filter(!(xmax >= 250 & xmin <= 7)) %>%
		filter(Time == tt) %>%
		slice(rep(1:n(), xmax-xmin+8)) %>%
		group_by(Iteration, Time) %>%
		mutate(x = xmin + row_number()-1) %>%
		
		filter(x < 256) %>%
		slice(rep(1:n(), ymax-ymin+8)) %>%
		group_by(Iteration, Time, x) %>%
		mutate(y = ymin + row_number()-1) %>%
		group_by(Time, x, y) %>%
		summarise(Count = n())
}

# 1.5 Transform the background image in a raster	
basegrob = rasterGrob(basepng, interpolate = FALSE) #interpolate = FALSE pour nearest neighbor

	



# 1.6 Export a png for each point in time
png(file=".\\img2\\flight%03d.png", width=256, height=224)
for(i in 1:length(unique_t)){
	{
	
	
	ggplot(df.pixel.hit[[i]]) +
		annotation_custom(basegrob, xmin=-Inf, xmax=Inf, ymin=-Inf, ymax=Inf)+
		geom_raster(aes(x = x+0.5, y = -y-0.5, alpha = Count), fill = '#a11bcd')+
		scale_x_continuous(lim = c(0,256),expand = c(0, 0))+
		scale_y_continuous(lim = c(-224,0), expand = c(0, 0))+
		scale_fill_continuous(guide = FALSE)+
		scale_alpha_continuous(guide = FALSE, range = c(0.4, 1), limits = c(0, 120)) + #set the minimum alpha at 0.4
		coord_fixed() +
		theme_void()+
		theme(axis.ticks.length = unit(0, "npc")) #remove border
	} %>%
	print()
}
dev.off()

# 1.7 Using windows shell, convert all pngs to a gif
shell('convert -delay 13.33333 -loop 0 ./img2/flight*.png ./img/flightpath.gif') #1.6667 = 60 framerate / 8 frame to shoot

