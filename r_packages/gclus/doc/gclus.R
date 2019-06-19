## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ------------------------------------------------------------------------
library(gclus)
data(longley)
longley.cor <- cor(longley)
longley.color <- dmat.color(longley.cor)

## ----fig.width=5, fig.height=5, fig.align='center'-----------------------
par(mar=c(1,1,1,1))
plotcolors(longley.color,dlabels=rownames(longley.color))

## ----eval=F--------------------------------------------------------------
#  longley.color <- dmat.color(longley.cor, byrank=FALSE)
#  longley.color <- dmat.color(longley.cor, breaks=c(-1,0,.5,.8,1),
#                              cm.colors(4))

## ----fig.width=5, fig.height=5, fig.align='center'-----------------------
par(mar=c(1,1,1,1))
longley.o <- order.hclust(longley.cor)
longley.color1 <- longley.color[longley.o,longley.o]
plotcolors(longley.color1,dlabels=rownames(longley.color1))

## ----fig.width=5, fig.height=5, fig.align='center'-----------------------
par(mar=c(1,1,1,1))
cpairs(longley, order= longley.o,panel.color= longley.color)

## ----fig.width=8, fig.height=3, fig.align='center', out.width="100%"-----
cparcoord(longley, order= longley.o,panel.color= longley.color, 
          horizontal=TRUE, mar=c(2,4,1,1))

## ----fig.width=6, fig.height=4, fig.align='center'-----------------------
par(mar=c(1,1,1,1))
data(eurodist)
dis <- as.dist(eurodist)
hc <- hclust(dis, "ave")
plot(hc)

## ----fig.width=6, fig.height=4, fig.align='center'-----------------------
par(mar=c(1,1,1,1))
hc1 <- reorder.hclust(hc, dis)
plot(hc1)

## ----fig.width=8, fig.height=3.5, fig.align='center'---------------------

layout(matrix(1:2,nrow=1,ncol=2))
par(mar=c(1,6,1,1))
cmat <- dmat.color(eurodist, rev(cm.colors(5)))
plotcolors(cmat[hc$order,hc$order], rlabels=labels(eurodist)[hc$order])

plotcolors(cmat[hc1$order,hc1$order], rlabels=labels(eurodist)[hc1$order])


