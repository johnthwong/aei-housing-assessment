# Instructions
# 1. Install R 4.5 or later.
# 2. After navigating to project root, run this script(cmd+shift+S in VS Code, or `Rscript setup.r`)

if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv")
renv::restore()
