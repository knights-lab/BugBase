## ---- include = FALSE----------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
library(ggplot2)

## ----ggproto-intro-------------------------------------------------------
A <- ggproto("A", NULL,
  x = 1,
  inc = function(self) {
    self$x <- self$x + 1
  }
)
A$x
A$inc()
A$x
A$inc()
A$inc()
A$x

## ----chull---------------------------------------------------------------
StatChull <- ggproto("StatChull", Stat,
  compute_group = function(data, scales) {
    data[chull(data$x, data$y), , drop = FALSE]
  },
  
  required_aes = c("x", "y")
)

## ------------------------------------------------------------------------
stat_chull <- function(mapping = NULL, data = NULL, geom = "polygon",
                       position = "identity", na.rm = FALSE, show.legend = NA, 
                       inherit.aes = TRUE, ...) {
  layer(
    stat = StatChull, data = data, mapping = mapping, geom = geom, 
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}

## ------------------------------------------------------------------------
ggplot(mpg, aes(displ, hwy)) + 
  geom_point() + 
  stat_chull(fill = NA, colour = "black")

## ------------------------------------------------------------------------
ggplot(mpg, aes(displ, hwy, colour = drv)) + 
  geom_point() + 
  stat_chull(fill = NA)

## ------------------------------------------------------------------------
ggplot(mpg, aes(displ, hwy)) + 
  stat_chull(geom = "point", size = 4, colour = "red") +
  geom_point()

## ------------------------------------------------------------------------
StatLm <- ggproto("StatLm", Stat, 
  required_aes = c("x", "y"),
  
  compute_group = function(data, scales) {
    rng <- range(data$x, na.rm = TRUE)
    grid <- data.frame(x = rng)
    
    mod <- lm(y ~ x, data = data)
    grid$y <- predict(mod, newdata = grid)
    
    grid
  }
)

stat_lm <- function(mapping = NULL, data = NULL, geom = "line",
                    position = "identity", na.rm = FALSE, show.legend = NA, 
                    inherit.aes = TRUE, ...) {
  layer(
    stat = StatLm, data = data, mapping = mapping, geom = geom, 
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}

ggplot(mpg, aes(displ, hwy)) + 
  geom_point() + 
  stat_lm()

## ------------------------------------------------------------------------
StatLm <- ggproto("StatLm", Stat, 
  required_aes = c("x", "y"),
  
  compute_group = function(data, scales, params, n = 100, formula = y ~ x) {
    rng <- range(data$x, na.rm = TRUE)
    grid <- data.frame(x = seq(rng[1], rng[2], length = n))
    
    mod <- lm(formula, data = data)
    grid$y <- predict(mod, newdata = grid)
    
    grid
  }
)

stat_lm <- function(mapping = NULL, data = NULL, geom = "line",
                    position = "identity", na.rm = FALSE, show.legend = NA, 
                    inherit.aes = TRUE, n = 50, formula = y ~ x, 
                    ...) {
  layer(
    stat = StatLm, data = data, mapping = mapping, geom = geom, 
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(n = n, formula = formula, na.rm = na.rm, ...)
  )
}

ggplot(mpg, aes(displ, hwy)) + 
  geom_point() + 
  stat_lm(formula = y ~ poly(x, 10)) + 
  stat_lm(formula = y ~ poly(x, 10), geom = "point", colour = "red", n = 20)

## ------------------------------------------------------------------------
#' @inheritParams ggplot2::stat_identity
#' @param formula The modelling formula passed to \code{lm}. Should only 
#'   involve \code{y} and \code{x}
#' @param n Number of points used for interpolation.
stat_lm <- function(mapping = NULL, data = NULL, geom = "line",
                    position = "identity", na.rm = FALSE, show.legend = NA, 
                    inherit.aes = TRUE, n = 50, formula = y ~ x, 
                    ...) {
  layer(
    stat = StatLm, data = data, mapping = mapping, geom = geom, 
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(n = n, formula = formula, na.rm = na.rm, ...)
  )
}


## ------------------------------------------------------------------------
StatDensityCommon <- ggproto("StatDensityCommon", Stat, 
  required_aes = "x",
  
  setup_params = function(data, params) {
    if (!is.null(params$bandwidth))
      return(params)
    
    xs <- split(data$x, data$group)
    bws <- vapply(xs, bw.nrd0, numeric(1))
    bw <- mean(bws)
    message("Picking bandwidth of ", signif(bw, 3))
    
    params$bandwidth <- bw
    params
  },
  
  compute_group = function(data, scales, bandwidth = 1) {
    d <- density(data$x, bw = bandwidth)
    data.frame(x = d$x, y = d$y)
  }  
)

stat_density_common <- function(mapping = NULL, data = NULL, geom = "line",
                                position = "identity", na.rm = FALSE, show.legend = NA, 
                                inherit.aes = TRUE, bandwidth = NULL,
                                ...) {
  layer(
    stat = StatDensityCommon, data = data, mapping = mapping, geom = geom, 
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(bandwidth = bandwidth, na.rm = na.rm, ...)
  )
}

ggplot(mpg, aes(displ, colour = drv)) + 
  stat_density_common()

ggplot(mpg, aes(displ, colour = drv)) + 
  stat_density_common(bandwidth = 0.5)

## ------------------------------------------------------------------------
StatDensityCommon <- ggproto("StatDensity2", Stat, 
  required_aes = "x",
  default_aes = aes(y = ..density..),

  compute_group = function(data, scales, bandwidth = 1) {
    d <- density(data$x, bw = bandwidth)
    data.frame(x = d$x, density = d$y)
  }  
)

ggplot(mpg, aes(displ, drv, colour = ..density..)) + 
  stat_density_common(bandwidth = 1, geom = "point")

## ------------------------------------------------------------------------
ggplot(mpg, aes(displ, fill = drv)) + 
  stat_density_common(bandwidth = 1, geom = "area", position = "stack")

## ------------------------------------------------------------------------
StatDensityCommon <- ggproto("StatDensityCommon", Stat, 
  required_aes = "x",
  default_aes = aes(y = ..density..),

  setup_params = function(data, params) {
    min <- min(data$x) - 3 * params$bandwidth
    max <- max(data$x) + 3 * params$bandwidth
    
    list(
      bandwidth = params$bandwidth,
      min = min,
      max = max,
      na.rm = params$na.rm
    )
  },
  
  compute_group = function(data, scales, min, max, bandwidth = 1) {
    d <- density(data$x, bw = bandwidth, from = min, to = max)
    data.frame(x = d$x, density = d$y)
  }  
)

ggplot(mpg, aes(displ, fill = drv)) + 
  stat_density_common(bandwidth = 1, geom = "area", position = "stack")
ggplot(mpg, aes(displ, drv, fill = ..density..)) + 
  stat_density_common(bandwidth = 1, geom = "raster")

## ----GeomSimplePoint-----------------------------------------------------
GeomSimplePoint <- ggproto("GeomSimplePoint", Geom,
  required_aes = c("x", "y"),
  default_aes = aes(shape = 19, colour = "black"),
  draw_key = draw_key_point,

  draw_panel = function(data, panel_scales, coord) {
    coords <- coord$transform(data, panel_scales)
    grid::pointsGrob(
      coords$x, coords$y,
      pch = coords$shape,
      gp = grid::gpar(col = coords$colour)
    )
  }
)

geom_simple_point <- function(mapping = NULL, data = NULL, stat = "identity",
                              position = "identity", na.rm = FALSE, show.legend = NA, 
                              inherit.aes = TRUE, ...) {
  layer(
    geom = GeomSimplePoint, mapping = mapping,  data = data, stat = stat, 
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}

ggplot(mpg, aes(displ, hwy)) + 
  geom_simple_point()

## ------------------------------------------------------------------------
GeomSimplePolygon <- ggproto("GeomPolygon", Geom,
  required_aes = c("x", "y"),
  
  default_aes = aes(
    colour = NA, fill = "grey20", size = 0.5,
    linetype = 1, alpha = 1
  ),

  draw_key = draw_key_polygon,

  draw_group = function(data, panel_scales, coord) {
    n <- nrow(data)
    if (n <= 2) return(grid::nullGrob())

    coords <- coord$transform(data, panel_scales)
    # A polygon can only have a single colour, fill, etc, so take from first row
    first_row <- coords[1, , drop = FALSE]

    grid::polygonGrob(
      coords$x, coords$y, 
      default.units = "native",
      gp = grid::gpar(
        col = first_row$colour,
        fill = scales::alpha(first_row$fill, first_row$alpha),
        lwd = first_row$size * .pt,
        lty = first_row$linetype
      )
    )
  }
)
geom_simple_polygon <- function(mapping = NULL, data = NULL, stat = "chull",
                                position = "identity", na.rm = FALSE, show.legend = NA, 
                                inherit.aes = TRUE, ...) {
  layer(
    geom = GeomSimplePolygon, mapping = mapping, data = data, stat = stat, 
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}

ggplot(mpg, aes(displ, hwy)) + 
  geom_point() + 
  geom_simple_polygon(aes(colour = class), fill = NA)

## ------------------------------------------------------------------------
GeomPolygonHollow <- ggproto("GeomPolygonHollow", GeomPolygon,
  default_aes = aes(colour = "black", fill = NA, size = 0.5, linetype = 1,
    alpha = NA)
  )
geom_chull <- function(mapping = NULL, data = NULL, 
                       position = "identity", na.rm = FALSE, show.legend = NA, 
                       inherit.aes = TRUE, ...) {
  layer(
    stat = StatChull, geom = GeomPolygonHollow, data = data, mapping = mapping,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}

ggplot(mpg, aes(displ, hwy)) + 
  geom_point() + 
  geom_chull()

## ------------------------------------------------------------------------
theme_grey()$legend.key

new_theme <- theme_grey() + theme(legend.key = element_rect(colour = "red"))
new_theme$legend.key

## ------------------------------------------------------------------------
new_theme <- theme_grey() %+replace% theme(legend.key = element_rect(colour = "red"))
new_theme$legend.key

## ----axis-line-ex--------------------------------------------------------
df <- data.frame(x = 1:3, y = 1:3)
base <- ggplot(df, aes(x, y)) + 
  geom_point() + 
  theme_minimal()

base
base + theme(text = element_text(colour = "red"))

