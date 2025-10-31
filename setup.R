# Setup script for tradefeatures package development
# Run this script to set up your development environment

# Install required packages
required_packages <- c(
        "devtools",
        "roxygen2",
        "testthat",
        "tibble",
        "dplyr",
        "rlang",
        "zoo",
        "TTR",
        "quantmod",
        "knitr",
        "rmarkdown"
)

cat("Installing required packages...\n")

for (pkg in required_packages) {
        if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
                cat("Installing", pkg, "...\n")
                install.packages(pkg)
        }
}

cat("\n✓ All required packages installed\n")

# Load development tools
library(devtools)
library(roxygen2)

# Document the package
cat("\nGenerating documentation...\n")
document()

# Run tests
cat("\nRunning tests...\n")
test()

# Check package
cat("\nChecking package...\n")
check()

cat("\n✓ tradefeatures development environment ready!\n")
cat("\nNext steps:\n")
cat("  1. Load package: devtools::load_all()\n")
cat("  2. Run examples: source('examples/basic_indicators.R')\n")
cat("  3. Run tests: devtools::test()\n")
cat("  4. Build vignettes: devtools::build_vignettes()\n")
cat("  5. View vignettes: browseVignettes('tradefeatures')\n")
