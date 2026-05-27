# Create Metric Over Time Plot

# load libraries ----
library(tidyverse)
library(tidymodels)
library(here)

# load results ----
results <- read_csv(here("autoresearch/results.csv"))

# create plot ----
results |> 
  ggplot(aes(x = iteration, y = j_index)) +
  geom_line() +
  theme_classic() +
  labs(
    title = "Youden's J Over Time",
    x = "Iteration #",
    y = "J Index"
  ) +
  geom_vline(xintercept = 38, linetype = "dashed", color = "red", size = 1) +
  geom_vline(xintercept = 59, linetype = "dashed", color = "blue", size = 1) +
  geom_vline(xintercept = 70, linetype = "dashed", color = "green", size = 1) +
  annotate("text", x = 39, y = 0.835, label = "End of Loop 1", 
           hjust = -0.1, color = "red") +
  annotate("text", x = 45, y = 0.81, label = "End of Loop 2", 
           hjust = -0.1, color = "blue") +
  annotate("text", x = 60, y = 0.82, label = "End of Loop 3",
           hjust = -0.1, color = "green")

ggsave(filename = "images/metric_over_time.png")
ggsave(filename = "images/metric_over_time.pdf")
