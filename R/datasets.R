#' Phenotypes of a subset of data set adapted from multic R package
#'
#' 29 first families were selected from the complete data set of 12000 individuals.
#'
#' Two simulated phenotypes possess a high genetic correlation.
#'
#' @format A data frame with 174 rows and 10 variables:
#' \describe{
#'   \item{famid}{Family ID (29 unique ids).}
#'   \item{id}{Individual ID.}
#'   \item{fa}{Father ID.}
#'   \item{mo}{Mother ID.}
#'   \item{sex}{Individual gender (1 - male, 2 - female).}
#'   \item{affect}{Affected status (1 - unaffected, 2 - affected).}
#'   \item{class}{Class label.}
#'   \item{trait1}{Simulated phenotype 1.}
#'   \item{trait2}{Simulated phenotype 2.}
#'   \item{age}{Age.}
#' }
#'
#' @source \url{http://cran.r-project.org/web/packages/multic/}
#'
#' @seealso \code{\link{genocovdat30}}, \code{\link{mapdat30}}
#'
#' @usage data(dat30)
#' @examples
#' data(dat30)
#'
#' str(dat30)
#'
#' plotPed(dat30, 2) # plot pedigree for family #2
#'
#' \dontrun{
#' kin2 <- solarKinship2(dat30)
#' plotKinship2(kin2) 
#' plotKinship2(kin2[1:30, 1:30])
#'
#' }
#'
"dat30"

#' Simulated genotypes for a subset of data set adapted from multic R package
#'
#' A hundred of synthetic SNPs were randomly generated for dat30 data set.
#' 
#' @format A matrix with 174 rows and 100 columns.
#'
#' The row names are IDs of individuals, the column names are the names of SNPs.
#'
#' @seealso \code{\link{dat30}}, \code{\link{mapdat30}}
#'
#' @usage data(dat30)
#' @examples
#' data(dat30)
#'
#' str(genocovdat30)
#'
#' genocovdat30[1:5, 1:5]
#'
"genocovdat30"

#' Annotation for simulated genotypes in a subset of data set adapted from multic R package
#'
#' A hundred of synthetic SNPs were randomly generated for dat30 data set.
#' Annotation also was generated to be plot the association results with Manhattan plot.
#' 
#' @format A data frame with 100 rows and 4 variables:
#' \describe{
#'   \item{SNP}{SNP name.}
#'   \item{chr}{Chromosome.}
#'   \item{pos}{Position in bp.}
#'   \item{gene}{Gene.}
#' }
#'
#' @seealso \code{\link{dat30}}, \code{\link{genocovdat30}}
#'
#' @usage data(dat30)
#' @examples
#' data(dat30)
#'
#' str(mapdat30)
#'
#' head(mapdat30)
#'
"mapdat30"
