# http://www.biostat.wustl.edu/genetics/geneticssoft/manuals/solar210/08.chapter.html
# 8.2 Kinship Coefficients: phi2.gz

K <- solarKinship2(dat30, coef = "d")
D <- solarKinship2(dat30, coef = "d")

plotKinship2(K[1:10, 1:10])
plotKinship2(D[1:10, 1:10])

