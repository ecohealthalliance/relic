library(targets)
list(
  tar_target(cars, mtcars),
  tar_target(cars_csv, {
    filename <- "cars.csv"
    write.csv(cars, filename)
    filename
  }, format = "file"),
  tar_target(cars_plot, {
    filename <- "cars.png"
    png(filename)
    plot(cars)
    dev.off()
    filename
  }, format = "file")
)
