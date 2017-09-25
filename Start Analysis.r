# 0 Prepare R

# 0.1 Set libraries
library(dplyr)
library(ggplot2)
library(magrittr)
library(png)
library(grid)
library(extrafont)

# 0.2 Set working directory
setwd('C:\\Users\\Guillaume\\Documents\\Nes\\Duck-Hunt')

# 0.3 Read dataset made using (RandomStart.lua)
df.RandomStart = read.csv('RandomStart.tsv', sep = '\t')

# 0.4 Import the background image
basepng = readPNG("Base.png", TRUE)











# 1 Starting position analysis
# 1.1 Aggregate horizontal pixel information
pixel.hit = 
	sapply(
		9:256,
		function(pixel) 
			{
				df.RandomStart %>%
				rowwise() %>%
				mutate(hit = between(pixel, xmin+1, xmax+8)) %>% #each individual box is 8 pixels wide
				{mean(.$hit)}
				
			}
	)
	


# 1.2 Transform the background image in a raster	
basegrob = rasterGrob(basepng, interpolate = FALSE)

# 1.3 Plot the graph
ggplot()+
	annotation_custom(basegrob, xmin=-Inf, xmax=Inf, ymin=-0.75, ymax=Inf)+ #Put the background image
	geom_rect(aes(xmin=-Inf, xmax=Inf, ymin=-Inf, ymax=Inf), fill = 'white', alpha = 0.7)+ #rectangle that whitens the background image 
	geom_hline(data = data.frame(y = c(0,0.1,0.2,0.3,0.4,0.5)), aes(yintercept = y), alpha = 0.2, linetype = 'dashed')+ #horizontal guidelines
	geom_area(data = data.frame(pixel = 1:256, avg.hit = c(numeric(8), pixel.hit)), aes(x = pixel, y = avg.hit), fill = '#1412a8', color = '#a11bcd', size = 1.2, alpha = 0.9) + 
	scale_x_continuous(lim = c(1,256), expand = c(0, 0))+
	scale_y_continuous(lim = c(-0.75,1.5), expand = c(0, 0), breaks = c(0,0.1,0.2,0.3,0.4,0.5), name = 'PROPORTION          ')+
	theme_minimal() + 
	theme(
		text=element_text(family="8bit",size = 16),  #8bit font by http://fontvir.us
		axis.text.x = element_blank(),
		axis.title.x = element_blank(),
		panel.grid.minor.x = element_blank(),
		panel.grid.major.x = element_blank()#,
		#panel.grid.major.y = element_line(color = '#a11bcd')
	)+ 
	coord_fixed(ratio = 100)

# 1.3 Save the graph
ggsave('start.png')
