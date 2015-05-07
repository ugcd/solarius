#' dat30 data set adapted from multic R package
#'
#' 29 first families were selected from the complete data set of 12000 individuals.
#' For a resulted subset of 174 individuals,
#' a hundred of synthetic SNPs were randomly generated.
#' Annotation information also was generated, 
#' mainly in order to plot the association results with Manhattan plot.
#' 
#' Two simulated phenotypes possess a high genetic correlation.
#'
#' @format 
#' (Phenotypes) A data frame \code{dat30} with 174 rows and 10 variables:
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
#' (Genotypes as covariates) A matrix \code{genocovdat30} with 174 rows and 100 columns.
#' Row names are IDs of individuals, column names are names of SNPs.
#'
#' (Annotation) A data frame \code{mapdat30} with 100 rows and 4 variables:
#' \describe{
#'   \item{SNP}{SNP name.}
#'   \item{chr}{Chromosome.}
#'   \item{pos}{Position in bp.}
#'   \item{gene}{Gene.}
#' }
#'
#' @source \url{http://cran.r-project.org/web/packages/multic/}
#'
#' @name dat30
#' @rdname dat30
#'
#' @usage data(dat30)
#' @examples
#' data(dat30)
#'
#' str(dat30)
#'
#' plotPed(dat30, 2) # plot the pedigree tree for family #2
#'
#' \dontrun{
#' kin2 <- solarKinship2(dat30)
#' plotKinship2(kin2) 
#' plotKinship2(kin2[1:30, 1:30])
#'
#' }
#'
"dat30"


#' @name genocovdat30
#' @rdname dat30
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

#' @name mapdat30
#' @rdname dat30
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


#' Phenotypes of dat50 data set adapted from FFBSKAT R package
#'
#' A mixture of unrelated and related individuals (a custom kinship matrix is given)
#' were originally simulated to test methods of the variant-collapsing approach.
#'
#' This data set is used here to test the ability of SOLAR 
#' to work with a custom kinship matrix in both polygenic and association analyses.
#'
#' @format A data frame with 66 rows and 4 variables:
#' \describe{
#'   \item{id}{Individual ID.}
#'   \item{sex}{Individual gender (0 - male, 1 - female).}
#'   \item{age}{Age.}
#'   \item{trait}{Simulated phenotype.}
#' }
#'
#' @source \url{http://mga.bionet.nsc.ru/soft/FFBSKAT/}
#'
#' @seealso \code{\link{kin}}, \code{\link{genodata}}, \code{\link{genocovdata}}, \code{\link{snpdata}}
#'
#' @usage data(dat50)
#' @examples
#' data(dat50)
#'
#' str(phenodata)
#'
"phenodata"

#' Kinship matrix for dat50 data set adapted from FFBSKAT R package
#'
#' @format A square matrix with 66 rows and 66 columns.
#'
#' @seealso \code{\link{phenodata}}, \code{\link{genodata}}, \code{\link{genocovdata}}, \code{\link{snpdata}}
#'
#' @usage data(dat50)
#' @examples
#' data(dat50)
#'
#' plotKinship2(2*kin)
#'
"kin"

#' Genotypes simulated for dat50 data set adapted from FFBSKAT R package
#'
#' 50 synthetic SNPs were generated.
#' The genotypes are coded in the format such as 1/1, 1/2 and 2/2.
#'
#' @format A matrix with 66 rows and 50 columns.
#'
#' @seealso \code{\link{phenodata}}, \code{\link{kin}}, \code{\link{genocovdata}}, \code{\link{snpdata}}
#'
#' @usage data(dat50)
#' @examples
#' data(dat50)
#'
#' str(genodata)
#'
#' genodata[1:5, 1:5]
#'
"genodata"


#' Genotypes as covariates in dat50 data set adapted from FFBSKAT R package
#'
#' 50 synthetic SNPs were generated.
#' A matrix of covariates was derived from the genotype data according to the additive model.
#'
#' @format A matrix with 66 rows and 50 columns.
#'
#' @seealso \code{\link{phenodata}}, \code{\link{kin}}, \code{\link{genodata}}, \code{\link{snpdata}}
#'
#' @usage data(dat50)
#' @examples
#' data(dat50)
#'
#' str(genocovdata)
#'
#' genocovdata[1:5, 1:5]
#'  
#' # compare with the genotypes
#' genodata[1:5, 1:5]
#'
"genocovdata"


#' Annotation for simulated genotypes in dat50 data set adapted from FFBSKAT R package
#'
#' @format A data frame with 100 rows and 4 variables:
#' \describe{
#'   \item{name}{SNP name.}
#'   \item{chrom}{Chromosome.}
#'   \item{position}{Position in bp.}
#'   \item{gene}{Gene.}
#' }
#'
#' @seealso \code{\link{phenodata}}, \code{\link{kin}}, \code{\link{genodata}}, \code{\link{genocovdata}}
#'
#' @usage data(dat50)
#' @examples
#' data(dat50)
#'
#' str(snpdata)
#'
#' head(snpdata)
#'
"snpdata"


