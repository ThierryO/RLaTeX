ubuntu_version <- function(package) {
  sprintf(
    "    %s=%s",
    package,
    gsub(
      ".*:\\s*",
      "",
      system(paste("apt-cache policy", package), intern = TRUE)[3]
    )
  )
}
system("apt-get update")
x <- sapply(
  c(
    "r-base-core","r-base-dev", "r-cran-boot", "r-cran-class", "r-cran-cluster",
    "r-cran-codetools", "r-cran-foreign", "r-cran-kernsmooth", "r-cran-lattice",
    "r-cran-mass", "r-cran-matrix", "r-cran-mgcv", "r-cran-nlme", "r-cran-nnet",
    "r-cran-rpart", "r-cran-spatial", "r-cran-survival", "r-recommended"
  ),
  ubuntu_version
)
cat(x, sep = " \\\n")

cat(ubuntu_version("littler"))
