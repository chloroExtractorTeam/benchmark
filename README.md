# Benchmark: chloroplast assembly from genomic data

## Status
1. Define the purpose and scope of the benchmark.
> automatic assembly tools extracting whole chloroplast genomes from mixed (plastid+genome) sequencing data

2. Include all relevant methods.
> GetOrganelle, fast-plast, org-asm, NOVOPlasty, chloroExtractor, IOGA
> TODO: is there another one we are missing?

3. Select (or design) representative datasets.
> We plan to use simulated data (at different chloro:genome ratios) and real datasets with existing reference chloroplasts
> TODO: select exact list of chloros 
> TODO: produce simulated datasets

4. Choose appropriate parameter values and software versions.
> Latest version of each (wrapped into a docker container), default parameters as possible
> TODO: update all docker containers
> TODO: select default parameters for each tool

5. Evaluate and rank methods according to key quantitative performance metrics.
> We currently only have qualitative metrics (success, failure, incomplete, ...)
> TODO: design quantitative metrics (reference guided: completeness, continuity, correctness)
> TODO: write script to gather these metrics from output

6. Evaluate secondary measures including runtimes and computational requirements,user-friendliness, code quality, and documentation quality.
> we have a script to track all performence metrics with docker
> TODO: separate performence benchmarking runs with docker
> TODO: find objective (as objective as possible) measures for requirements, user-friendliness, code quality and documentation
> TODO: assign these metrics to all tools

7. Interpret results and provide guidelines or recommendations from both user and method developer perspectives.
> in addition to pure metrics keep an eye on complementarity, maybe recommend ensemble methods
> TODO

8. Publish and distribute results in an accessible format.
> GitHub, zenodo, DockerHub, biorXiv, BMC
> TODO

9. Design the benchmark to enable future extensions.
> We have that with the docker setup and having scripted everything
> TODO: documentation on GitHub on how to reproduce the benchmarking (incl. extension)

10. Follow reproducible research best practices, in particular by making all code and data publicly available.
> Already covered with all previous points
