# TaCHS-Aqueous-NADES-MD

Classical molecular dynamics simulations of chalcone synthase from *Triticum aestivum* (TaCHS) in water and aqueous natural deep eutectic solvent (NADES) environments.

This repository contains the simulation inputs, system-preparation files, and computational workflows used to investigate how aqueous NADES composition and concentration affect the structural dynamics, stability, and active-site environment of dimeric TaCHS. The simulated systems include choline chloride- and betaine-based NADES containing glycerol, ethylene glycol, or xylitol at different concentrations, together with a water control.


## Systems

| Directory | Solvent system | Available concentration labels |
| --- | --- | --- |
| `ChCl_Gly` | Choline chloride + glycerol | 10, 25, 50, 75 |
| `ChCl_EG` | Choline chloride + ethylene glycol | 10, 25, 50, 75 |
| `ChCl_Xyl` | Choline chloride + xylitol | 10, 25 |
| `Betaine_Gly` | Betaine + glycerol | 10, 25, 50, 75 |
| `Betaine_EG` | Betaine + ethylene glycol | 10, 25, 50, 75 |
| `nonades` | Water control | 1 |

The NADES labels correspond to the aqueous NADES percentages used in the
project. Exact molecular populations are recorded in each topology's
`[ molecules ]` section.

## Repository layout

```text
mdp/          GROMACS parameter files for minimization, equilibration, and MD
scripts/      Full production workflow and a short pipeline smoke test
structures/   Reference molecular and protein structures
systems/      Local user-prepared coordinate files (not tracked by Git)
topology/     System topologies, molecule parameters, restraints, and force field
```

The protocol was tested with GROMACS 2022.1. Coordinate (`.gro`) and compiled
run-input (`.tpr`) files under `systems/` are intentionally ignored because
they are large or version-dependent. Generate new `.tpr` files from the text
topology and `.mdp` inputs.

## Requirements

- GROMACS 2022.1 or a compatible version
- Bash
- A prepared, solvated, neutralized coordinate file for a new simulation

## Prepare a starting structure

Starting structures are intentionally not duplicated in the repository. Prepare
the solvated and neutralized system using your preferred workflow, then save it
with this convention:

```text
systems/<NADES>/start_<concentration>.gro
```

For example:

```text
systems/ChCl_Gly/start_50.gro
```

The molecule identities, counts, and ordering in the coordinate file must match
the corresponding `topology/<NADES>/topol_<concentration>.top`. Update the
topology `[ molecules ]` section when constructing a system with different
populations.

## Run the workflow

Edit the three configuration values near the top of `scripts/run_gromacs.sh`:

```bash
NADES="ChCl_Gly"
CONCENTRATION="50"
GPU_ID="0"
```

Then run:

```bash
./scripts/run_gromacs.sh
```

Outputs are written under `runs/<NADES>/<concentration>/`. The workflow runs:

| Stage | Parameter file | Nominal length |
| --- | --- | ---: |
| Energy minimization | `mini.mdp` | up to 5,000 steps |
| NVT 1 | `NVT.mdp` | 1 ns |
| NVT 2 | `NVT_1.mdp` | 1 ns |
| NVT 3 | `NVT_2.mdp` | 20 ns |
| NVT 4 | `NVT_3.mdp` | 1 ns |
| NPT | `npt.mdp` | 2 ns |
| Production | `md_3.mdp` | 200 ns |

Before committing a protocol change, run the short end-to-end check:

```bash
./scripts/test_gromacs_pipeline.sh
```

The smoke test uses the same user-prepared starting structure, limits each stage
to ten steps, and writes its outputs beneath `runs/smoke_test/`.

## Force field and provenance

Protein parameters use the included `amber14sb_parmbsc1.ff` GROMACS force
field. The bundled force-field README records its upstream provenance and a
local correction to the sodium Lennard-Jones epsilon value. NADES component
parameters and system-specific restraint files are stored beside each topology.

The MIT license applies to the original scripts and repository documentation.
Bundled force-field and parameter data retain their upstream provenance and
terms; users are responsible for confirming that those terms are appropriate
for redistribution and their intended use.

## Scientific context

TaCHS is a plant chalcone synthase (type III polyketide synthase) that produces
chalcone scaffolds in flavonoid biosynthesis. This repository supports the
investigation of aqueous NADES as a media-engineering strategy for modulating
TaCHS activity, stability, and its active-site environment. Related project
results indicate that selected NADES conditions can compact the active-site
cavity while preserving overall protein structure.

## Citation

Citation metadata is provided in `CITATION.cff`. Publication-specific citation
details can be added when the associated study is published.

## License

Original code and documentation are released under the MIT License. See
`LICENSE` and the force-field provenance note above.
