# Suppress R CMD check notes for ggplot2 aes() variables that are columns
# in data frames constructed inside functions, not true globals.
utils::globalVariables(c("time", "emp", "pred", "res", "sim", "x", "density"))
